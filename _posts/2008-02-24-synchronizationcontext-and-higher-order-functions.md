---
layout: post
---
It's often useful to ensure that actions occur on specific threads, in
particular event handlers.?? Take Windows Forms for instance where all
operations on a Control must occur on the thread it was created on.?? Typically
this is not a problem since WinForms respond to events such as Click, Move,
etc...?? These events are sourced from the same thread so it's not an issue.

But there are cases where events are sourced from a separate thread and we
need to Marshal it back onto the Control thread.?? One good example of this is
[FileSystemWatcher](http://msdn2.microsoft.com/en-
us/library/system.io.filesystemwatcher.aspx).?? If a SynchronizationObject is
not provided it will raise the event on an unspecified thread.?? This event
cannot directly touch a Control or an "Illegal cross thread call exception"
will occur.?? Many examples use ISynchronizedInvoke to marshal the code back.
There are a couple of downsides to this approach including

  1. ISynchronizedInvoke on Controls won't work until the Handle is created or after it's destroyed.?? So if the event fires in either of these cases an unhandled exception will occur and typically crash the process. 
  2. Can't use an anonymous lambda because ISynchronizedInvoke is not typed to a specific delegate 
  3. Code is easy to get subtly wrong 

Here is an example implementation.

    
    
            private void OnFileChanged(object sender, FileSystemEventArgs e)


            {


                if( this.InvokeRequired )


                {


                    // If the handle is not created this will throw


                    Invoke((MethodInvoker)(() => OnFileChanged(sender, e)));


                    return;


                }


    


                textBox2.Text = String.Format("{0} {1}", e.ChangeType, e.Name);


            }

It would be easier if we could bind a delegate to a particular thread in such
way that calls automatically marshal to the appropriate thread.?? Imagine for
instance if we could type the following in such a way that all invocations of
"del" below would automatically marshal to the thread for the Control.?? We
could then freely pass this to any event source and not have to worry about
what thread the event is raised on.

    
    
    var del = SynchronizationContext.Current.BindDelegateAsPost(new FileSystemEventHandler(OnFileChanged));

Instead of ISynchronizedInvoke we'll use
[SynchronizationContext](http://msdn2.microsoft.com/en-
us/library/system.threading.synchronizationcontext.aspx).?? IMHO this is a
better approach for this type of work.?? It has the same functionality as
ISynchronizedInvoke and helps with a few of the quirks.?? The Windows Forms
Application Model (and if memory serves WPF) insert a
[SynchronizationContext](http://msdn2.microsoft.com/en-
us/library/system.threading.synchronizationcontext.aspx) for every thread
running a WinForm application.?? It greatly reduces the chance your code will
run into problem #1 above because the timespan for when it can be used to
Marshal between threads is not dependent upon the internal workings of a
particular Control.?? Instead it's tied to the lifetime of the Thread[1].

The basic strategy we'll take is to create a new delegate which wraps the
original delegate.?? This will Marshal the call onto the appropriate thread and
then call the original delegate.
[SynchronizationContext](http://msdn2.microsoft.com/en-
us/library/system.threading.synchronizationcontext.aspx) has two methods to
Marshal calls between threads; Post and Send.

Creating a delegate instance on the fly is not straight forward.?? Unless we
code all permutations of delegate signatures into a class we cannot use the
Delegate.Create API because we cannot provide a method with the matching
signature.?? Instead we need to go through Reflection.Emit.?? This allows us to
build a method on the fly to match the delegate signature.?? In addition we can
generate the IL to route the code through Post/Send before calling the
delegate.

First up are extension methods for
[SynchronizationContext](http://msdn2.microsoft.com/en-
us/library/system.threading.synchronizationcontext.aspx) that call into a
helper class.

    
    
    public static T BindDelegateAsPost<T>(this SynchronizationContext context, T del)


    {


        return DelegateFactory.CreateAsPost(context, del);


    } 
    
    
    public static T BindDelegateAsSend<T>(this SynchronizationContext context, T del)


    {


        return DelegateFactory.CreateAsSend(context, del);


    }

Next is a class which injects the Send/Post call.?? We need this as a storage
mechanism for holding the context and delegate.?? Essentially this is a hand
generate closure.

    
    
        private class DelegateData


        {


            private SynchronizationContext m_context;


            private Delegate m_target;


    


            internal DelegateData(SynchronizationContext context, Delegate target)


            {


                m_target = target;


                m_context = context;


            }


    


            public void Send(object[] args)


            {


                m_context.Send(() => m_target.DynamicInvoke(args));


            }


    


            public void Post(object[] args)


            {


                m_context.Post(() => m_target.DynamicInvoke(args));


            }


        }

Now comes the actual delegate generation.?? The dynamic method will be bound to
an instance of the DelegateData class.?? As such we must add an additional
parameter to the delegate of type DelegateData in position 0.?? The rest of the
method creates an object array with length equal to the number of parameters
in the delegate.?? Each of the arguments are added to this array.?? Then it will
call Post/Send in DelegateData passing the arguments along.

    
    
        private static T Create<T>(SynchronizationContext context, T target, string name)


        {


            Delegate del = (Delegate)(object)target;


            if (del.Method.ReturnType != typeof(void))


            {


                throw new ArgumentException("Only void return types currently supported");


            }


    


            var paramList = new List<Type>();


            paramList.Add(typeof(DelegateData));


            paramList.AddRange(del.Method.GetParameters().Project((x) => x.ParameterType));


            var method = new DynamicMethod(


                "AMethodName",


                del.Method.ReturnType,


                paramList.ToArray(),


                typeof(DelegateData));


            var gen = method.GetILGenerator();


            var localInfo = gen.DeclareLocal(typeof(object[]));


            gen.Emit(OpCodes.Ldc_I4, paramList.Count - 1);


            gen.Emit(OpCodes.Newarr, typeof(object));


            gen.Emit(OpCodes.Stloc, localInfo.LocalIndex);


            for (int i = 1; i < paramList.Count; ++i)


            {


                gen.Emit(OpCodes.Ldloc, localInfo.LocalIndex);


                gen.Emit(OpCodes.Ldc_I4, i - 1);


                gen.Emit(OpCodes.Ldarg, i);


                if (paramList[i].IsValueType)


                {


                    gen.Emit(OpCodes.Box);


                }


                gen.Emit(OpCodes.Stelem_Ref);


            }


    


            gen.Emit(OpCodes.Ldarg_0);


            gen.Emit(OpCodes.Ldloc, localInfo.LocalIndex);


            gen.EmitCall(OpCodes.Call, typeof(DelegateData).GetMethod(name, BindingFlags.Instance | BindingFlags.Public), null);


            gen.Emit(OpCodes.Ret);


            return (T)(object)method.CreateDelegate(typeof(T), new DelegateData(context, del));


        }


    


        internal static T CreateAsSend<T>(SynchronizationContext context, T target)


        {


            return Create(context, target, "Send");


        }


    


        internal static T CreateAsPost<T>(SynchronizationContext context, T target)


        {


            return Create(context, target, "Post");


        }

The resulting delegate is now of the same type as the original delegate and
invocations will occur on the targeted thread.

[1] Granted if you try to use a
[SynchronizationContext](http://msdn2.microsoft.com/en-
us/library/system.threading.synchronizationcontext.aspx) to Marshal between
threads after the target thread has finished you will still get an error.


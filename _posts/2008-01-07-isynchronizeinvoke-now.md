---
layout: post
---
[ISynchronizeInvoke](http://msdn2.microsoft.com/en-
us/library/system.componentmodel.isynchronizeinvoke.aspx) is an interface
which allows you to execute a delegate synchronously or asynchronously.  The
implementer of the interface can control how the delegate is executed.  In
particular the implementer controls on which thread the delegate is executed.

It's common for thread sensitive objects to implement this interface.  It
allows consumers to execute long lived actions on a background thread and then
use the ISynchronizeInvoke interface to get back onto the original thread.
System.Windows.Forms.Control is a great example of this usage pattern.

Several API's that I own are very thread aware and will often defer to a
background thread for the completion of their operation.  It makes it easier
to build UI on top of it.  They take an ISynchronizedInvoke as a parameter in
order to properly signal the caller than an operation is completed.

The difficulty can come in testing it.  Many implementers of
ISynchronizeInvoke use message pumping to implement the behavior.  As a result
it's not always easy to use for testing (unit testing in particular).  To work
around this I designed an implementation of ISynchronizeInvoke that does not
rely on the message pumping but provides a completely compliant
ISynchronizeInvoke implementation.

The idea is to just do it ... now.  I call the class ImmediateInvoke.  The
basic methods are straight forward.

    
    
            object ISynchronizeInvoke.Invoke(Delegate method, object[] args)


            {


                return method.DynamicInvoke(args);


            }


    


            bool ISynchronizeInvoke.InvokeRequired


            {


                get { return false; }


            }

The other two methods are a little more tricky.  The require an implementation
of [IAsyncResult](http://msdn2.microsoft.com/en-
us/library/system.iasyncresult.aspx).  The basic usage pattern is the consumer
will call BeginInvoke, peform some operations and finally call EndInvoke when
it wants to join with the asynchronous operation.  I will use the thread pool
to perform this operation and define a private nested class for the
IAsnycResult implementation called AsyncResult

The implementation needs a few variables to implement the contract.

  * m_handle - An implementation of ManualResetEvent to satisfy the AsyncWaitHandle property
  * m_completed - A simple int to capture whether or not we have completed
  * m_return - Return of the delegate
  * m_exception - Exception thrown by calling the delegate. 

Most of the properties are straight forward.

    
    
                public object AsyncState


                {


                    get { return this; }


                }


    


                public System.Threading.WaitHandle AsyncWaitHandle


                {


                    get { return m_handle; }


                }


    


                public bool CompletedSynchronously


                {


                    get { return false; }


                }


    


                public bool IsCompleted


                {


                    get { return m_completed == 1; }


                }

Now we need to define a method to run the delegate passed to BeginInvoke in
the thread pool and update the state as we go along.  I call this method
directly from the constructor.

    
    
                private void RunDelegateAsync(Delegate method, object[] args)


                {


                    WaitCallback del = delegate(object unused)


                    {


                        try


                        {


                            object temp = method.DynamicInvoke(args);


                            Interlocked.Exchange(ref m_return, temp);


                        }


                        catch (Exception ex)


                        {


                            Interlocked.Exchange(ref m_exception, ex);


                        }


    


                        Interlocked.Exchange(ref m_completed, 1);


                        m_handle.Set();


                    };


    


                    ThreadPool.QueueUserWorkItem(del);


                }

Notice I've avoided using a lock in this implementation.  This is safe for
this case.  All of the members are set atomically.  Only m_completed can be
accessed before the operation is completed and it is simply checked for the
value 1.  Since the value is set atomically this is safe.  In the
implementation of EndInvoke I will not access any of the other variables until
the WaitHandle is signaled and then I will not make any decision based on the
contents of their values (rather the abscence or presence).

Also notice that I did not explicitly dispose of the WaitHandle.  This is a
quirk of the ISynchronizeInvoke interface.  It specifies that callers of
BeginInvoke must call EndInvoke and that the IAsyncResult must be valid until
EndInvoke is called.  As such you can't really free a resource inside of the
IAsyncResult implementation.  In fact if you implement IDisposable, who will
see it (generally not possible since C# and VB don't support covariant return
types).  Instead you should free it as part of your EndInvoke implementation.

Now BeginInvoke and EndInvoke.

    
    
            IAsyncResult ISynchronizeInvoke.BeginInvoke(Delegate method, object[] args)


            {


                return new AsyncResult(method, args);


            }


    


            object ISynchronizeInvoke.EndInvoke(IAsyncResult result)


            {


                var r = (AsyncResult)result;


                try


                {


                    r.AsyncWaitHandle.WaitOne();


                }


                finally


                {


                    r.AsyncWaitHandle.Close();


                }


    


                if (r.m_exception != null)


                {


                    throw new Exception("Error during BeginInvoke", r.m_exception);


                }


                return r.m_return;


            }

Unfortunately EndInvoke has to take care of two cases.  The first is the
delegate completed successfully and produced a value which can now be returned
as a part of the interface contract.  The other case is when the delegate
throws and exception and it's a bit more tricky.  The exception cannot be
simply re-thrown because you will loose all of the original call stack and
generally speaking most of the data which would help track down the problem.
The better option is to throw a new exception and make this exception the
inner exception.

This sample could be improved in a few ways (delay create the WaitHandle,
rethrow with something other than System.Exception).  But it's a compliant
version that gets the job done.


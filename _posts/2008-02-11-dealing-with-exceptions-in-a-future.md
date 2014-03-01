---
layout: post
---
Besides waiting, the another important issue when dealing with Futures is how
to deal with exceptions thrown by the user specified code.

**Option 1: Ignore the Exception**

Don't take any actions in the future code and force users to write exception
free code. IMHO this is not the best way to approach the problem. The code
will be running in the thread pool and unhandled exceptions in the thread pool
result in the taking down of an appdomain/process. In addition Futures are
designed to be simple. Adding a try/catch around every lambda is not
practical and/or readable.

**Option 2: Catch and Swallow**

Catch the exception on the background thread and swallow it. Silently failing
is in many cases worse than actually crashing. Behavior will become flaky and
the user/developer won't have any indication there is an error.

**Option 3: Re-throw the Exception when Wait is called**

Catch and save the exception when it occurs on the background thread. Then
when Wait() is called on a Future re-throw the exception. This makes
exception handled deterministic.

It's also very similar to the exception handling semantics of calling a
method. The only difference is that users must handle the exception at the
point of method completion vs invocation. For synchronous methods this is
just the same point.

The big downside to this approach is the stack trace information is lost from
the exception. Re-throwing will instead add the stack trace at the point of
the re-throw. Not having stack trace information makes it very difficult to
actually track down the source of an error.

**Option 4: Re-throw a new Exception when Wait is called **

This is very similar to Option #3. The only difference is when the user calls
Wait, throw a new exception and make the original exception an inner exception
of the new one. We'll call this exception FutureException. This has the
advantages of option 3 and in addition will preserve the stack trace
information from the original exception.

There is a downside to this approach though. Users can no longer have
different catch blocks to handle the different types of exceptions that can be
thrown.

    
    
                try


                {


                    Future.Create(() => SomeOperation());


                }


                catch (IOException ex)


                {


                    // ...


                }


                catch (InvalidOperationException ex)


                {


                    // ...


                }

Instead the user can only catch a Future exception and examine the inner
result to take corrective action.

    
    
                try


                {


                    Future.Create(() => SomeOperation());


                }


                catch (FutureException ex)


                {


                    var type = ex.InnerException.GetType();


                    if (type == typeof(IOException))


                    {


                        // ...


                    }


                    else if (type == typeof(InvalidOperationException))


                    {


                        // ...


                    }


                }

This doesn't actually limit any functionality but users may find the syntax
uncomfortable. VB users can still do exception filtering but this is not at
option for C# users.

    
    
            Try


                Future.Create(Function() SomeOperation())


            Catch ex As Exception When ex.InnerException.GetType() Is GetType(IOException)


    


            End Try

The FutureException class is straight forward. A simple implementation of the
exception snippet will do the trick.

    
    
        [global::System.Serializable]


        public class FutureException : Exception


        {


    


    


            public FutureException() { }


            public FutureException(string message) : base(message) { }


            public FutureException(string message, Exception inner) : base(message, inner) { }


            protected FutureException(


              System.Runtime.Serialization.SerializationInfo info,


              System.Runtime.Serialization.StreamingContext context)


                : base(info, context) { }


        }


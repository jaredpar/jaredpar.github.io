---
layout: post
---
In the end there are two basic types of Future implementations you can use.

  1. Futures which return no values 
  2. Futures which return a value 

The rest of the behavior and shape of the Future is the same and screams for a
pattern of sorts. I've found the best way to implement this behavior is
through an inheritance pattern. The base class is name of course Future.
It's purpose is to provide a common way in which to schedule the invocation of
a delegate, [handle
exceptions](http://blogs.msdn.com/jaredpar/archive/2008/02/11/dealing-with-
exceptions-in-a-future.aspx), wait for the completion of such delegate and
enforce certain contracts such as not running the future more than once.

At the core it only needs a few members.

  1. [ActiveOperation](http://blogs.msdn.com/jaredpar/archive/2008/02/04/the-first-part-of-building-a-future-is-waiting.aspx) m_operation which is used to implement the waiting portion 
  2. int m_run used to ensure a future is not run twice 
  3. Exception m_error to record any exceptions thrown by running the delegate 
    
    
            private ActiveOperation m_operation = new ActiveOperation();


            private int m_run;


            private Exception m_error;

It has one public property to determine whether or not a Future has completed.
It's a proxy into m_operation

    
    
            public bool HasCompleted


            {


                get { return m_operation.HasCompleted; }


            }

By using m_operation to deal with Waiting, the majority of WaitEmpty can be
proxied to m_operation as well. The only additional work needed is to deal
with Exceptions.

    
    
            public void WaitEmpty()


            {


                m_operation.Wait();


                if (m_error != null)


                {


                    throw new FutureException("Error occurred running future", m_error);


                }


            }

The only behavior a child class needs is a place to invoke the delegate. A
single abstract method is provided to allow implement this behavior.

    
    
            protected abstract void RunCore();

Before calling this method the base Future class must make sure that all of
the contracts are met. This is implemented through a wrapper method around
RunCore. It is the only method that calls RunCore directly.

    
    
            private void RunWrapper()


            {


                if (0 != Interlocked.CompareExchange(ref m_run, 1, 0))


                {


                    throw new InvalidOperationException("Future is already run");


                }


    


                try


                {


                    RunCore();


                }


                catch (Exception ex)


                {


                    Interlocked.Exchange(ref m_error, ex);


                }


                finally


                {


                    m_operation.Completed();


                }


            }

It's very important that m_operation is signalled as completed after exception
handling occurs. The setting or not setting of m_error is the only way we
know if an exception occurred when waiting. If we do this in the opposite
order it's possible for WaitEmpty() to complete before the exception is set
and hence miss the error.

Lastly is the code to actually run the Future. There are two ways to run the
Future (more can be added).

  1. Asynchronously through the ThreadPool. This is the more common case. 
  2. Synchronously on the same thread. This will mainly be used to implement such operations as methods in Active Objects. 
    
    
            public void Run()


            {


                RunWrapper();


            }


    


            public void RunInThreadPool()


            {


                ThreadPool.QueueUserWorkItem((x) => RunWrapper());


            }

This leaves us with a base class implementation for Future's. Next we'll
implement Future which return values.


---
layout: post
---
Future's are a great abstraction for asynchronous programming.  One of the
items making them so good is the easy manner in which you can declare one and
wait for it to finish.  The idea is to allow for many futures to be declared
with as little overhead as possible.  In order to do so you need to define an
efficient way of waiting.

Normally when you need to wait on operations between two threads to complete
you use a Thread.Join call or a form of a WaitHandle.  I tend to prefer a
[ManualResetEvent](http://msdn2.microsoft.com/en-
us/library/system.threading.manualresetevent.aspx).

Unfortunately a [ManualResetEvent](http://msdn2.microsoft.com/en-
us/library/system.threading.manualresetevent.aspx) is not free and under the
hood will allocate a kernel handle.  There are a lot of handles to go around
and while unlikely that a program purely using futures will allocate too many
handles, you may be running with other code that is handle hungry.

In addition several cases do not need a handle.  For instance in the below
code, if the commented out section takes longer than the future to complete
then why do you even need wait handle of any sort?

    
    
               var d = Future.Create(() => CallASimpleFunction);


                // ...


                d.Wait();

Therefore the first step is to define an efficient waiting mechanism.  I call
it an ActiveOperation.  It provides 3 basic methods; HasCompleted, Completed
and Wait.  It optimizes for trying to not created a WaitEvent unless actually
necessary.  It has two member variables.  An int for completion check and a
[ManualResetEvent](http://msdn2.microsoft.com/en-
us/library/system.threading.manualresetevent.aspx) to be used for shared
waiting when necessary.  Notice that m_hasCompleted is not volatile, instead
all writes use a Interlocked operation to ensure it is propagated between
threads.

    
    
            private int m_hasCompleted;


            private ManualResetEvent m_waitEvent;

HasCompleted is straightforward.

    
    
            public bool HasCompleted


            {


                get { return m_hasCompleted == 1; }


            }

Completed is a little bit trickier.  It has to deal with a couple of cases.

  1. Another thread already called Completed. 
  2. Completed called before another thread calls Wait. 
  3. Completed called while or after another thread calls Wait.  
    
    
            public void Completed()


            {


                if (0 == Interlocked.CompareExchange(ref m_hasCompleted, 1, 0))


                {


                    ManualResetEvent mre = m_waitEvent;


                    if (mre != null)


                    {


                        try


                        {


                            mre.Set();


                        }


                        catch (ObjectDisposedException)


                        {


                            // If another thread is in Wait at the same time and sees the completed flag


                            // it may dispose of the shared event.  In this case there is no need to signal


                            // just return.


                        }


                    }


                }


            }

Wait is the trickiest one.  It has the following cases to deal with

  1. HasCompleted already set 
  2. Second or later thread to call Wait and needs to wait on m_waitEvent 
  3. While attempting to create m_waitEvent, another thread in Wait finishes first. 
  4. Thread successfully creates and owns the shared m_waitEvent variable before Completed() is called. 
  5. During the creation of m_waitEvent, another thread calls Completed() in which case there is no guarantee that m_waitEvent will be signaled. 
    
    
            public void Wait()


            {


                // Case 1


                if (HasCompleted)


                {


                    return;


                }


    


                // Case 2


                ManualResetEvent sharedEvent = m_waitEvent;


                if (sharedEvent != null)


                {


                    WaitOnEvent(sharedEvent);


                }


    


                ManualResetEvent created = null;


                try


                {


                    created = new ManualResetEvent(false);


                    sharedEvent = Interlocked.CompareExchange(ref m_waitEvent, created, null);


                    if (null != sharedEvent)


                    {


                        // Case 3.  Another thread got here first and it's created is now the shared event.  Wait


                        // on that event


                        WaitOnEvent(sharedEvent);


                    }


                    else if (HasCompleted)


                    {


                        // Case 5. In between the time we checked for completion and created the event a completion


                        // occurred.  Returning will dispose of m_waitEvent and force other threads Wait to complete 


                        return;


                    }


                    else


                    {


                        // Case 4. 


                        WaitOnEvent(created);


                    }


                }


                finally


                {


                    if (created != null )


                    {


                        if ( sharedEvent == null)


                        {


                            Interlocked.Exchange(ref m_waitEvent, null);


                        }


    


                        created.Close();


                    }


                }


            }


    


            private void WaitOnEvent(ManualResetEvent mre)


            {


                try


                {


                    mre.WaitOne();


                }


                catch (ObjectDisposedException)


                {


    


                }


            }

Now you have one of the basic building blocks of Futures.


---
layout: post
---
Before we can get to building an Active Object implementation, there are some more primitive structures we need to define.  Active Objects live on a separate thread where every call is executed in a serialized fashion on that thread.  The next primitive will allow us to easily pass messages in the form of delegates from the caller to the background thread.

The structure must support adding messages from N callers but only needs to support 1 reader (the active object).  Successive writes from the same thread should add the items in their respective order.  The input end of the pipe can be closed while leaving the output end active.  This allows for the consumer to deterministically reach an end state while not ignoring any any input.

The name of the structure is PipeSingleReader.

Designing a thread safe mutable structure is significantly different from a non-thread safe or immutable data structure.  There is a significant temptation to apply existing patterns.  We should question every pattern we apply to these collections.  Many of these patterns lead us to design API's which encourage bad programming practices.

Our existing collection patterns are designed around structures which behave deterministically on any given thread because they are 1) Immutable or 2) designed for single thread use only.  Many of these concepts do not apply to mutable thread safe collections because they are constantly being accessed and mutated by multiple threads.  This gives them the _appearance _of behaving non-deterministically with respect to a given thread.  

Take the member Count for instance.  This is found on virtually every collection class in the BCL.  Yet having it on a mutable thread safe collection class only leads to programming errors.  The only reason to have a member such is Count is to use it to make a decision.   However in a mutable thread-safe collection making a decision off of this value is wrong.  The value can and will change between any two instructions in code.

Take the example below.  Just because the Count is >0 in the if block has no dependable relevance to what the value will be inside the if block.

``` csharp
var ThreadSafeList<int> col = GetList();
if( col.Count > 0 )
{
    //...
}
```

To guard against this and have users of the collections avoid the pit of failure members such as Count should not appear on mutable thread-safe collections.

Instead we'll design API's around the functionality of this structure.  The input end of the structure is straight forward.  All writers want is to add data.

The output end is more interesting.  The end goal is to read output from the pipe but how to deal with cases where there is no data.   Some programs will want to check for data, others block until data is available.   We can define three methods to satisfy most scenarios

  * WaitForOutput - void method which blocks until input is available
  * GetNextOutput - Blocks until input is available and returns it
  * TryGetOutput - Returns immediately.  If output is available it will be returned.
    
``` csharp
public class PipeSingleReader<T> : IDisposable {
    private readonly ThreadAffinity m_affinity = new ThreadAffinity();
    private readonly Queue<T> m_queue = new Queue<T>();
    private readonly AutoResetEvent m_event = new AutoResetEvent(false);
    private readonly object m_lock = new object();
    private bool m_inputClosed;

    public PipeSingleReader() {
    }

    #region Dispose
    public void Dispose() {
        Dispose(true);
        GC.SuppressFinalize(this);
    }
    ~PipeSingleReader() {
        Dispose(false);
    }
    private void Dispose(bool disposing) {
        if (disposing) {
            m_event.Close();
        }
    }
    #endregion
    public void WaitForOutput() {
        m_affinity.Check();
        do {
            lock (m_lock) {
                if (m_queue.Count > 0) {
                    return;
                }
            }
            m_event.WaitOne();
        } while (true);
    }
    public T GetNextOutput() {
        m_affinity.Check();
        T data;
        while (!TryGetOutput(out data))
        {
            m_event.WaitOne();
        } 
        return data;
    }
    public bool TryGetOutput(out T value) {
        m_affinity.Check();
        lock (m_lock) {
            if (m_queue.Count == 0) {
                value = default(T);
                return false;
            }

            value = m_queue.Dequeue();
            return true;
        }
    }
    public void AddInput(T value) {
        lock (m_lock) {
            if (m_inputClosed) {
                throw new InvalidOperationException("Input end of pipe is closed");
            }
            m_queue.Enqueue(value);
        }
        m_event.Set();
    }
    public void CloseInput() {
        lock (m_lock) {
            m_inputClosed = true;
        }
    }
}
```

At a quick glance it may seem odd in GetNextOutput that I loop around m_event being set and TryGetOutput.  Why loop?  Shouldn't a single check for the settness of m_event be enough?  In this case no.  The reason why is TryGetOutput will remove output from the queue without resetting the settness of m_event.  Thus m_event can be set without actually having any data in m_queue.  In general the implementation must treat m_event being set as the possibility of data rather than a guarantee.

This implementation uses locks to synchronize access to the data.  In general I'm a fan of avoiding locks when possible since it's very easy to miss trivial cases.  Next time we'll look at an implementation of PipeSingleReader which avoids the use of locks.


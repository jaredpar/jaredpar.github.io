---
layout: post
---
Previously we discussed a multi-thread safe [queue like data structure]({% post_url 2008-03-02-pipesinglereader %}) using locks as an internal synchronization mechanism.  This time we'll look at a version requiring no locks.

In the previous version, locks were used to synchronize access to an underlying queue which stored the data.  Removing the locks necessitates us moving away from Queue<T> to store the data and forces us onto another structure which is safe in the presence of multiple threads.  

Immutable collections are safe in the presence of multiple threads and don't require any synchronization mechanisms.  However they're immutable and we're trying to build a mutable data structure?  No matter.  Even though each instance is immutable they can be used to create new instances which represent a somewhat mutated state.

For this exercise we will be using a slight variant of Eric Lippert's [Immutable Stack](http://blogs.msdn.com/ericlippert/archive/2007/12/04/immutability-in-c-part-two-a-simple-immutable-stack.aspx) implementation [^1].  The pipe will have two stacks; 1) for capturing input and 2) for storing output.  Named m_writeStack and m_readStack respectively.

This makes the implementation of reading input straight forward.  While m_readStack is not empty the reader thread can systematically pop off the values.  This doesn't require any contention with writer threads and since their is only one reader thread and the stack is immutable the code is straight forward.  Once the m_readStack is empty the reader thread will swap out the current state of m_writeStack with an empty stack.  The original value will be reversed so we can maintain the FIFO ordering and set as the new m_readStack.

     
``` csharp
private bool CheckForInput() {
    if( m_readerStack.IsEmpty ) {
        var prev = Interlocked.Exchange(ref m_writerStack, ImmutableStack<T>.Empty);
        m_readerStack = prev.Reverse();
    }
    return !m_readerStack.IsEmpty;
}
```

Writing data is more complicated because it must deal with contention for updating the same data structure.  It can be altered by other writers or the reader thread when it runs out of data.  Basically it must push a value onto the stack and update the m_writerStack to point to the new value.  In between the operations the value of m_writerStack could change and thus invalidate the push.  To guard against this the writer must guarantee the current value of the m_writerStack is the same as it was before the push operation.  Interlocked.CompareExchange will do the trick.  If it's been changed then repeat the operation.

    
``` csharp
public void AddInput(T value) {
    bool done;
    do {
        if (m_inputClosed) {
            throw new InvalidOperationException("Input end of pipe is closed");
        }
        var originalStack = m_writerStack;
        var newStack = originalStack.Push(value);
        var currentStack = Interlocked.CompareExchange(ref m_writerStack, newStack, originalStack);
        done = object.ReferenceEquals(currentStack, originalStack);
    } while (!done);
    m_event.Set();
}
```

At a glance it may seem like this suffers from the [ABA problem](http://en.wikipedia.org/wiki/ABA_problem).  This is not the case and it's easy to prove.  In between the read and push operation only two other operations can modify the m_writeStack variable.  The first is another write which will produce a new value of ImmutableStack<T>.  In this case the CLR guarantees that the references will not be equal and the CAS operation won't succeed.  The second is the reader thread swaps out the value and replaces it with Empty.  It's possible to hit an ABA situation here (detailed below) but fundamentally if it was empty before and empty now the operation is still safe.  No data is lost because we are still replacing an empty stack with a single value'd stack.  

Here's a more elaborate version starting with an empty pipe of type int

  1. Thread 1: Begins to write 5 and is stopped just before the CAS operation
    1. originalStack points to ImmutableStack<int>.Empty
  2. Thread 2: Starts and completes a write of the value 6
  3. Thread 3: Reads a value from the pipe, having no data replaces m_writeStack with ImmutableStack<int>.Empty
  4. Thread 1: Resumes and the CAS succeeds even though the m_writeStack technically changed in the middle of the operation

Even though this exhibits many characterstics of the ABA pattern it is not a problem because the behavior is still correct.  No data was lost because it was transferred to the reader thread.  The end result is m_writeStack pointing to a single vaue'd stack containing the data 5 which is valid.  The pipe does not guarantee the ordering of data between writer threads (merely the ordering between a single writer thread).

Below is the implementation in it's entirety.

    
``` csharp
public class PipeSingleReaderNoLock<T> : IDisposable {
    private readonly ThreadAffinity m_affinity = new ThreadAffinity();
    private ImmutableStack<T> m_readerStack = ImmutableStack<T>.Empty;
    private ImmutableStack<T> m_writerStack = ImmutableStack<T>.Empty;
    private readonly AutoResetEvent m_event = new AutoResetEvent(false);
    private volatile bool m_inputClosed;

    public PipeSingleReaderNoLock() {
    }

    #region Dispose
    public void Dispose() {
        Dispose(true);
        GC.SuppressFinalize(this);
    }
    ~PipeSingleReaderNoLock() {
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
        while (!CheckForInput()) {
            m_event.WaitOne();
        }
    }
    public T GetNextOutput() {
        m_affinity.Check();
        T data;
        while (!TryGetOutput(out data)) {
            m_event.WaitOne();
        }
        return data;
    }
    public bool TryGetOutput(out T value) {
        m_affinity.Check();
        if (CheckForInput()) {
            value = m_readerStack.Peek();
            m_readerStack = m_readerStack.Pop();
            return true;
        }
        else {
            value = default(T);
            return false;
        }
    }
    private bool CheckForInput() {
        if (m_readerStack.IsEmpty) {
            var prev = Interlocked.Exchange(ref m_writerStack, ImmutableStack<T>.Empty);
            m_readerStack = prev.Reverse();
        }
        return !m_readerStack.IsEmpty;
    }
    public void AddInput(T value) {
        bool done;
        do {
            if (m_inputClosed) {
                throw new InvalidOperationException("Input end of pipe is closed");
            }
            var originalStack = m_writerStack;
            var newStack = originalStack.Push(value);
            var currentStack = Interlocked.CompareExchange(ref m_writerStack, newStack, originalStack);
            done = object.ReferenceEquals(currentStack, originalStack);
        } while (!done);
        m_event.Set();
    }
    public void CloseInput() {
        m_inputClosed = true;
    }
```

[^1]: If you haven't read this series you really should.


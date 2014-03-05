---
layout: post
---
In my last [post](http://blogs.msdn.com/jaredpar/archive/2009/02/11/why-are-thread-safe-collections-so-hard.aspx) we discussed the problems with designing a safer API for mutable thread safe collections that employ only an internal locking system.  The result was an API that was more difficult to mess up, yet pretty much unusable.  Lets take a look at this problem and see if we can come up with a usable API that still helps to eliminate mistakes.

One of the main issues I have with mutable thread safe collections is the use of decision procedures such as Count and Contains.  Procedures such these only return information that pertains to the collection as it existed at a previous point in time.  It can provide no relevant information to the collection in it's current state and only encourages the user to write bad code.  For example.

    
{% highlight csharp %}
if (col.Count > 0) {  
    // Collection can be modified before this next line executes leading to   
    // an error condition  
    var first = col[0];   
}
{% endhighlight %}

Therefore they have no place on a mutable thread safe collection.  Yet, once you take away these procedures, you're left with a collection that is virtually useless.  It can only have a minimal API by which to access data.  Here is the last example we were left with

{% highlight csharp %}
public sealed class ThreadSafeList<T> {  
    public void Add(T value) { ... }  
    public bool TryRemove(T value) { ... }  
    public bool TryGet(int index, out T value) { ... }  
}
{% endhighlight %}

This is hardly a usable API.  What's worse, as wekempf point out, is that I inadvertently exposed a decision procedure in this API.  It's possible to infer state about a lower or equal index by a successful return result from TryGet().  For example, a user may say that 'if I can access element 2, then surely element 1 must exist'.  The result would still be evident in code (ignoring the return value of a TryGet method should be a red flag).  But a better choice for this method would have been a TryGetFirst().

At the end of the day, users are going to want some level of determinism out of their collections.  It's possible to program against API's like the above, but most people won't do it.  In order to be more used, the collection must be able to reliably implement procedures such as Count and Contains and allow the user to use the return to reason about the state of the collection.  

One way to do this is to simply exposed the internal lock to the consumer of the collection.  Consumers can take the lock and then query to their hearts content.  Lets do a quick modification of the original sample to allow for this.

    
{% highlight csharp %}
public sealed class ThreadSafeList<T> {  
    private List<T> m_list = new List<T>();  
    private object m_lock = new object();  
  
    public object SyncLock { get { return m_lock; } }  
  
    public void Add(T value) {  
        lock (m_lock) {  
            m_list.Add(value);  
        }  
    }  
    public void Remove(T value) {  
        lock (m_lock) {  
            m_list.Remove(value);  
        }  
    }  
    public bool Contains(T value) {  
        lock (m_lock) {  
            return m_list.Contains(value);  
        }  
    }  
    public int Count { get { lock (m_lock) { return m_list.Count; } } }  
    public T this[int index] {  
        get { lock (m_lock) { return m_list[index]; } }  
        set { lock (m_lock) { m_list[index] = value; } }  
    }  
}
{% endhighlight %}

Now we can go back to the original sample code and write a version which can use the decision procedures safely.

{% highlight csharp %}
lock (col.SyncLock) {  
    if (col.Count > 0) {  
        var first = col[0];  
        ...  
    }  
}
{% endhighlight %}

This code will function correctly.  But the API leaves a lot to be desired.  In particular '

  1. It provides no guidance to the user as to which procedures must be accessed with the SyncLock object locked.  They can just as easily write the original bad sample code. 
  2. All procedures used within the lock reacquire the lock recursively which is definitely [not advisable](http://zaval.org/resources/library/butenhof1.html).  We could provide properties which do not acquire the lock such as CountNoLock that work around this problem. While ok in small doses, it's just a matter of time before you see this snippet in the middle of a huge mostly undocumented function
    
    // Lock should be held at this point  
    int count = col.CountNoLock;

This code makes my eyes bleed

  3. The API provides 0 information to the user on exactly what the rules are for this lock.  It would be left as an artifact in documentation (which you simply cannot count on users reading). 
  4. There is really nothing telling the user that they ever have to unlock the collection.  Surely, any user entering into the world of threading should know this but if they do a Monitor.Enter call without a corresponding Monitor.Exit, they will receive no indication this is a bad idea. 
  5. Overall this collection requires a lot of new knowledge about the collection to use 

This design though is exactly how a 'synchronized' collection in 1.0 version of the BCL worked.  This code is essentially what you would get by passing an ArrayList instance to ArrayList.Synchronized (and most other BCL 1.0 collections).   It was problematic enough that all of the new collections in 2.0 did not implement this _feature_.  Here's the BCL team's explanation on this <http://blogs.msdn.com/bclteam/archive/2005/03/15/396399.aspx>

Overall this design poses several problems because it exposes internal implementation details directly to the consumer.  An improved design should seek to hide the lock from direct access.  What we really want is a way to not even provide API's like Count and Contains unless the object is already in a locked state.  This prevents them from being used at all in an incorrect scenario.

Lets run with this idea to design a more usable thread safe queue.  First we'll divide the interface for a queue into two parts.

  1. All procedures that have 0 reliance on the internal state of the collection.  Namely Enqueue, and Clear.  No state is required to use these methods 
  2. All procedures that rely on the internal state of the collection to function correctly. 

The ThreadSafeQueue class will contain all of the methods in category #1.  It will also provide a method which returns an instance of an interface which has all of the methods in category #2.

{% highlight csharp %}
public interface ILockedQueue<T> : IDisposable{  
    int Count { get; }  
    bool Contains(T value);  
    T Dequeue();  
}
{% endhighlight %}

The implementation of this interface object will acquire the internal lock of the original ThreadSafeQueue during construction and hold it for the duration if it's lifetime.  This effectively freezes the queue allowing for decision procedures to be used reliably.  Implementing IDisposable and releasing the lock in the Dispose method provides a measure of lifetime management.  

The rest of the code sample is below.

{% highlight csharp %}
public sealed class ThreadSafeQueue<T> {  
  
    #region LockedQueue  
    private sealed class LockedQueue : ILockedQueue<T> {  
        private ThreadSafeQueue<T> m_outer;  
        internal LockedQueue(ThreadSafeQueue<T> outer) {  
            m_outer = outer;  
            Monitor.Enter(m_outer.m_lock);  
        }  
  
        #region ILockedQueue<T> Members  
        public int Count {   
            get { return m_outer.m_queue.Count; }  
        }  
        public bool Contains(T value) {  
            return m_outer.m_queue.Contains(value);  
        }  
        public T Dequeue() {  
            return m_outer.m_queue.Dequeue();  
        }  
        #endregion  
        #region IDisposable Members  
        public void Dispose() {  
            Dispose(true);  
            GC.SuppressFinalize(this);  
        }  
        private void Dispose(bool disposing) {  
            Debug.Assert(disposing, "ILockedQueue implementations must be explicitly disposed");   
            if (disposing) {  
                Monitor.Exit(m_outer.m_lock);  
            }  
        }  
        ~LockedQueue() {  
            Dispose(false);  
        }  
        #endregion  
    }  
    #endregion  
  
    private Queue<T> m_queue = new Queue<T>();  
    private object m_lock = new object();  
  
    public ThreadSafeQueue() { }  
    public void Enqueue(T value) {  
        lock (m_lock) {  
            m_queue.Enqueue(value);  
        }  
    }  
  
    public void Clear() {  
        lock (m_lock) {  
            m_queue.Clear();  
        }  
    }  
  
    public ILockedQueue<T> Lock() {  
        return new LockedQueue(this);  
    }  
}
{% endhighlight %}

This design now cleanly separates out the two modes by which the collection can be asked.  It completely hides the explicit synchronization aspects from the users and replaces it with design patterns (such as IDisposable) that they are likely already familiar with.  Now our original bad sample can be rewritten as follows.

    
{% highlight csharp %}
static void Example1(ThreadSafeQueue<int> queue) {  
    using (var locked = queue.Lock()) {  
        if (locked.Count > 0) {  
            var first = locked.Dequeue();  
        }  
    }  
}
{% endhighlight %}

No explicit synchronization code is needed by the user.  This design makes it much harder for the user to make incorrect assumptions or misuses of the collection.  The 'decision procedures' are simply not available unless the collection is in a locked state.

As with most thread safe designs, there are ways in which this code can be used incorrectly

  1. Using an instance of ILockedQueue<T> after it's been disposed.  This though is already considered taboo though and we can rely on existing user knowledge to help alleviate this problem.  Additionally, static analysis tools, such as FxCop, will flag this as an error.  With a bit more rigor this can also be prevented. Simply add a disposed flag and check it on entry into every method.
  2. It's possible for the user to maintain values, such as Count, between calls to Lock and use it to make an incorrect assumption about the state of the list. 
  3. If the user fails to dispose the ILockedQueue<T> instance it will be forever locked.  Luckily FxCop will also flag this as an error since it's an IDisposable.  It's not a foolproof mechanism though. 
  4. There is nothing that explicitly says to the user 'please only use ILockedQueue<T> for a very short time'.  IDisposable conveys this message to a point but it's certainly not perfect.
  5. The actual ILockedQueue<T> implementation is not thread safe.  Ideally users won't pass instances of IDisposable between threads but it is something to think about.

The good news is that two of these flaws (1 and 3) are issues with existing types and tools are already designed to weed them out.  FxCop will catch common cases for both of them.

Also, many of these cases are considered bad code in the absence of a thread safe collection.  This allows users to rely on existing knowledge instead of forcing them to learn new design patterns for mutable thread safe collections.  

Overall I feel like this design is a real win over the other versions.  It provides an API which helps to limit the mistakes a user can make with a mutable thread safe collection without requiring a huge deal of new patterns in order to use.


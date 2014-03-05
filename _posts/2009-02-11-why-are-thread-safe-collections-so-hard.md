---
layout: post
---
Writing a collection which is mutable, thread safe and usable is an extremely difficult process.  At least that's what you've likely been told all through your schooling.  But then you get out on the web and see a multitude of thread safe lists, maps and queues.  If it's so hard, why are there so many examples?

The problem is there are several levels of thread safe collections.  I find that when most people say thread safe collection what they really mean 'a collection that will not be corrupted when modified and accessed from multiple threads'.   Lets call this 'data thread safe' for brevity.  This type of collection is rather easy to build.  Virtually any collection that is not thread safe can be made 'data thread safe' by synchronizing access via a simple locking mechanism.

For Example, lets build a data thread safe List<T>.

{% highlight csharp %}
public sealed class ThreadSafeList<T> : IEnumerable<T> {  
    private List<T> m_list = new List<T>();  
    private object m_lock = new object();  
  
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
    // IEnumerable<T> left out  
}
{% endhighlight %}

And there you have it.  The lock statement prevents concurrent access from multiple threads.  So the actual m_list instance is only ever accessed by a single thread at a time which is all it's designed to do.  This means instances of ThreadSafeList<T> can be used from any thread without fear of corrupting the underlying data.

But if building a data thread safe list is so easy, why doesn't Microsoft add these standard collections in the framework?

Answer: ThreadSafeList<T> is a virtually unusable class because the design leads you down the path to bad code.

The flaws in this design are not apparent until you examine how lists are commonly used.  For example,  take the following code which attempts to grab the first element out of the list if there is one.

    
{% highlight csharp %}
static int GetFirstOrDefault(ThreadSafeList<int> list) {  
    if (list.Count > 0) {  
        return list[0];  
    }  
    return 0;  
}
{% endhighlight %}

This code is a classic race condition.  Consider the case where there is only one element in the list.  If another thread removes that element in between the if statement and the return statement, the return statement will throw an exception because it's trying to access an invalid index in the list.  Even though ThreadSafeList<T> is data thread safe, there is nothing guaranteeing the validity of a return value of one call across the next call to the same object.  

I refer to procedures like Count as decision procedures.  They server only to allow you to make a decision about the underlying object.  Decision procedures on a concurrent object are virtually useless.  As soon as the decision is returned, you must assume the object has changed and hence you cannot use the result to take any action.

Decision procedures are one of the reasons why [Immutable Collections](http://code.msdn.microsoft.com/BclExtras) are so attractive.  They are both data thread safe and allow you to reason about there APIs.  Immutable Collections don't change **ever**.  Hence it's perfectly ok to have decision procedures on them because the result won't get invalidated.

The fundamental issue with ThreadSafeList<T> is it is designed to act like a List<T>.  Yet List<T> is not designed for concurrent access.   When building a mutable concurrent collection, in addition to considering the validity of the data, you must consider how design the API to deal with the constantly changing nature of the collection.

When designing a concurrent collection you should follow different guidelines than for a normal collection class.  For example.

  1. Don't add an decision procedures.  They lead users down the path to bad code. 
  2. Methods which query the object can always fail and the API should reflect this. 

Based on that, lets look at a refined design for ThreadSafeList<T>

{% highlight csharp %}
public sealed class ThreadSafeList<T> {  
    private List<T> m_list = new List<T>();  
    private object m_lock = new object();  
  
    public void Add(T value) {  
        lock (m_lock) {  
            m_list.Add(value);  
        }  
    }  
    public bool TryRemove(T value) {  
        lock (m_lock) {  
            return m_list.Remove(value);  
        }  
    }  
    public bool TryGet(int index, out T value) {  
        lock ( m_lock ) {  
            if( index < m_list.Count ) {  
                value = m_list[index];  
                return true;  
            }  
            value = default(T);  
            return false;  
        }  
    }  
}
{% endhighlight %}

Summary of the changes

  * Both the Contains and Count procedures were removed because they were decision procedures 
  * Remove was converted to TryRemove to indicate it's potential to fail 
  * The TryGet property was added and is reflective of the fragile nature of the method.  Sure it's possible for users to simply ignore the return value and plow on with the invalid value.  However the API is not lulling the user into a false sense of security 
  * The collection no longer implements IEnumerable<T>.  IEnumerable<T> is only valid when a collection is not changing under the hood.  There is no way to easily make this guarantee with a collection built this way and hence it was removed. 
  * The indexers were removed as well.  I'm a bit wishy washy in this particular point as there is nothing in the API which gives a user a false sense of security.  But at the same time mutable concurrent collections are dangerous and should be treated with a heightened sense of respect so the indexers were removed. 

This version of ThreadSafeList is more resilient, but not immune to, accidental user failure.  The design tends to lead users on the path to better code.

But is it really usable?  Would you use it in your application?


---
layout: post
---
Part of creating a multithreading program is understanding which threads objects live on. Seems simple enough and typically is. However it's nice to insert guarantees to match the design.

One type of threading model is for objects or subsets of methods in an object to have an affinity to a particular thread. Meaning that those methods can only be validly called on a particular thread and no other. I create a small helper object to help validate this affinity.

Simple, but gets the job done.

{% highlight csharp %}
[Immutable]
public sealed class ThreadAffinity
{
    private readonly int m_threadId;

    public ThreadAffinity()
    {
        m_threadId = Thread.CurrentThread.ManagedThreadId;
    }

    public void Check()
    {
        if (Thread.CurrentThread.ManagedThreadId != m_threadId)
        {
            var msg = String.Format(
                "Call to class with affinity to thread {0} detected from thread {1}.",
                m_threadId,
                Thread.CurrentThread.ManagedThreadId);
            throw new InvalidOperationException(msg);
        }
    }
}
{% endhighlight %}


---
layout: post
---
Recently I had to test a class which heavily depended upon a [SynchronizationContext](http://msdn.microsoft.com/en-us/library/system.threading.synchronizationcontext.aspx). This threw me off for about half an hour as I didn't want to write multi-threaded unit tests.  Multi-threaded code is difficult enough without adding needless threads.  

The solution I came up with is simple and gives the unit test a large degree of control over the execution of posted delegates. The resulting tests were much easier to code and understand.

    
``` csharp
public sealed class TestSynchronizationContext : SynchronizationContext {
    private List<Tuple<SendOrPostCallback, object>> m_pending 
        = new List<Tuple<SendOrPostCallback, object>>();

    public override void Send(SendOrPostCallback d, object state) {
        d(state);
    }

    public override void Post(SendOrPostCallback d, object state) {
        m_pending.Add(Tuple.Create(d, state));
    }

    public void RunAllPosted() {
        m_pending.ForEach(x => x.First(x.Second));
    }
}
```


---
layout: post
---
I've been busy lately and neglected my series on [Active Objects]({% post_url 2008-01-28-active-objects-and-futures %}). It's been a fairly busy time for me both in and out of work.  Enough excuses, back to the fun.

With the basic [PipeSingleReader]({% post_url 2008-03-02-pipesinglereader %}) class, we now have the last piece necessary to create an ActiveObject. This article will focus on building the base ActiveObject which will take care of scheduling, construction, destruction and error handling. The goal is to make implementing an ActiveObject that actually does work easy.

Lets break down the implementation of an ActiveObject into the three phases of any object; construction, destruction and running behavior.

### Construction

Active Objects are associated with and have an affinity to a particular thread. Constructing an ActiveObject mainly consists of creating a thread and initializing the member variables of the object.

There are a couple of requirements that need to be met when initializing the object. The first is getting the thread into a known state before returning out of the constructor. It's possible for coders to create and then immediately destroy an object. Part of destructing an object is understanding the state you are destructing. Returning from an ActiveObject constructor before the thread is up and running means that we can be destructed while in an inconsistent state. Normally this isn't much an issue with objects because they are single threaded. We will fix this by doing a simple wait until the thread is finished initializing.

    
``` csharp
protected ActiveObject() {
    m_thread = new Thread(() => InitializeAndRunBackgroundThread());
    m_thread.Start();
    while (0 == m_backgroundInitialized) { Thread.Sleep(0); }
}
```

Next is providing implementers with a way to initialize member variables on the new thread. There are many reasons for wanting to initialize members on the ActiveObject thread. Besides general consistency concerns, there is also the issue that objects can have affinity to a particular thread and including forcing initialization to occur on that thread. To make this simple part of the thread initialization code will call a virtual method allowing base classes to initialize variables.

    
``` csharp
private void InitializeAndRunBackgroundThread() {
    Interlocked.Exchange(ref m_affinity, new ThreadAffinity());
    Interlocked.Exchange(ref m_pipe, new PipeSingleReader<Future>());
    InitializeMembersInBackground();
    Interlocked.Exchange(ref m_backgroundInitialized, 1);
    RunBackgroundActions();
}
protected virtual void InitializeMembersInBackground() {
}
```

### Running Behavior

Active Objects exist for one reason, to run Futures. The main behavior is to loop over the set of Futures and run them. The PipeSingleReader class takes care of most of the scheduling and threading work. This leaves the ActiveObject free to make policy decisions.

One question that comes up is how to handle the case where a Future throws an exception' If we run the Future with no protection it will simple cause an unhandled exception and likely a process crash. We could catch and try to filter them but based on what criteria' IMHO there is no way to properly handle an exception in the Active Object base because we don't know what the purpose of that object is. Only the actual object implementer knows.  Therefore we will make it their problem by passing unhandled exceptions into an abstract method.

``` csharp
private void RunBackgroundActions() {
    do {
        RunFuture(m_pipe.GetNextOutput());
    } while (0 == m_backgroundFinished);
    Future future;
    while (m_pipe.TryGetOutput(out future)) {
        RunFuture(future);
    }
}
private void RunFuture(Future future) {
    try {
        m_affinity.Check();
        future.Run();
    }
    catch (Exception ex) {
        OnBackgroundUnhandledException(ex);
    }
}
```

If the second loop looks a bit out of place, hopefully the destruction section will explain it's purpose.

All that is left is to provide helper methods to let base classes queue up Futures to run.

``` csharp
protected Future RunInBackground(Action action) {
    var f = Future.CreateNoRun(action);
    m_pipe.AddInput(f);
    return f;
}
protected Future<T> RunInBackground<T>(Func<T> func) {
    var f = Future.CreateNoRun(func);
    m_pipe.AddInput(f);
    return f;
}
```

### Destruction

Destruction of an ActiveObject can be tricky with respect to handling pending actions. Should they be executed, aborted or just completely ignored' What happens if more input is added once we start the dispose process' If we don't allow more input where should we error?

IMHO, the simplest user and programming model is the following.

  1. Dispose is synchronous. It will block until the background thread is destroyed. Dispose is the equivalent of destruction so it follows that all resources including the thread will be destroyed when destruction completes.
  2. Once dispose starts input will be stopped. This prevents live-lock scenarios where one thread is disposing the ActiveObject and another thread is constantly adding data.
  3. If another thread tries to add an operation during the middle of disposing they will be given an exception at that time.

In future posts, we'll explore how to create ActiveObjects with differing dispose semantics.

Now how can we signal the background thread that we are done processing' Just add a future to the queue to be running. Because this will run on the only thread reading the int there is no need for an Interlocked operation.  
    
``` csharp
private void Dispose(bool disposing) {
    if (disposing) {
        m_pipe.AddInput(Future.CreateNoRun(() => { m_backgroundFinished = 1; }));
        m_pipe.CloseInput();
        m_thread.Join();
    }
}
```

Now that we've gone over the dispose code, hopefully the reason for the second loop in RunBackgroundActions is a little more apparent. Between the two calls to m_pipe in Dispose another thread can post a Future. Without the second loop the user will get no exception and the future will never run. Likely they would hopelessly deadlock.'? The second loop will run all Futures which get caught it this gap.

### The Code

Here is the full version of the code.

``` csharp
public abstract class ActiveObject :  IDisposable {
    private PipeSingleReader<Future> m_pipe;
    private ThreadAffinity m_affinity;
    private Thread m_thread;
    private int m_backgroundInitialized;
    private int m_backgroundFinished;

    protected ActiveObject() {
        m_thread = new Thread(() => InitializeAndRunBackgroundThread());
        m_thread.Start();
        while (0 == m_backgroundInitialized) { Thread.Sleep(0); }
    }
    #region Dispose
    public void Dispose() {
        Dispose(true);
        GC.SuppressFinalize(this);
    }
    ~ActiveObject() {
        Dispose(false);
    }
    private void Dispose(bool disposing) {
        if (disposing) {
            m_pipe.AddInput(Future.CreateNoRun(() => { m_backgroundFinished = 1; }));
            m_pipe.CloseInput();
            m_thread.Join();
        }
    }
    #endregion
    private void InitializeAndRunBackgroundThread() {
        Interlocked.Exchange(ref m_affinity, new ThreadAffinity());
        Interlocked.Exchange(ref m_pipe, new PipeSingleReader<Future>());
        InitializeMembersInBackground();
        Interlocked.Exchange(ref m_backgroundInitialized, 1);
        RunBackgroundActions();
    }
    private void RunBackgroundActions() {
        do {
            RunFuture(m_pipe.GetNextOutput());
        } while (0 == m_backgroundFinished);
        Future future;
        while (m_pipe.TryGetOutput(out future)) {
            RunFuture(future);
        }
    }
    private void RunFuture(Future future) {
        try {
            m_affinity.Check();
            future.Run();
        }
        catch (Exception ex) {
            OnBackgroundUnhandledException(ex);
        }
    }
    protected Future RunInBackground(Action action) {
        var f = Future.CreateNoRun(action);
        m_pipe.AddInput(f);
        return f;
    }
    protected Future<T> RunInBackground<T>(Func<T> func) {
        var f = Future.CreateNoRun(func);
        m_pipe.AddInput(f);
        return f;
    }
    protected virtual void InitializeMembersInBackground() {
    }
    protected abstract void OnBackgroundUnhandledException(Exception ex);
}
```

---
layout: post
---
Like most generic classes, I prefer to create Future instances through static factory methods which allows me to take maximum advantage of type inference.

In addition to the 2 straight forward declaration of Func<T> and Action, the methods will include overloads which take in Func<T> with varying numbers of arguments.  The overloads will cury the arguments and create a Func<T> taking no arguments.  This is a great convenience to the user and takes little extra code to implement.

In addition because we don't expose the EmptyFuture class directly we need to provide a factory method to create it in a non-run state.  Otherwise we are forcing the EmptyFuture to always be created and run in the ThreadPool.

``` csharp
public static Future Create(Action action)
{
    var f = new EmptyFuture(action);
    f.RunInThreadPool();
    return f;
}

public static Future Create<TArg1>(Action<TArg1> action, TArg1 arg1)
{
    return Create(() => action(arg1));
}

public static Future<T> Create<T>(Func<T> func)
{
    var f = new Future<T>(func);
    f.RunInThreadPool();
    return f;
}

public static Future<TReturn> Create<TArg1,TReturn>(Func<TArg1, TReturn> func, TArg1 arg1)
{
    return Create(() => func(arg1));
}

public static Future<T> CreateNoRun<T>(Func<T> func)
{
    return new Future<T>(func);
}

public static Future CreateNoRun(Action action)
{
    return new EmptyFuture(action);
}
```


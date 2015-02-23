---
layout: post
title: The curious case of Task.Run not starting
tags: [c#]
---

Recently I was confused about the interaction between `Task` and `CancellationToken`.  In particular I couldn't remember if a `Task` which was already running was marked cancelled as soon as the associated `CancellationToken` was cancelled or if it waited until it had completed. The documentation wasn't much help so I decided to write up a quick program to test out the behavior: 

``` csharp
static void Main(string[] args)
{
    CancellationTokenSource cts = new CancellationTokenSource();
    Task t = Task.Run(() => { while (true); }, cts.Token);
    cts.Cancel();
    Console.WriteLine(t.Status);
}
```

This `Task` never completes so it should answer my question pretty easily.  It will either print out "Canceled" (does immediately cancel) or "WaitingToRun / Running" (waits for completion).  To my surprise though this printed out: 

> WaitingForActivation

Say what?  A `Task` created with `Task.Run` should be started automatically, it should never be waiting for activation.  That's one of the advantages to this API.  

This behavior had me puzzled quite a bit.  Enough so that I ended up emailing Stephen Toub about it.  Between the two of us we were able to track the behavior down to a quick of both the C# compiler and the `Task` APIs.  

The C# quirk involves how the lambda conversion is processed.  In this case the compiler detects the method never returns because it has an infinite loop. The compiler allows lambdas that never return to convert to delegate of any return type that is otherwise compatible [1].  Hence it can convert equally well to `Func<Task>` as it can to `Action`.  

This comes into play when we consider all of the overloads available for `Task.Run`:

``` csharp
public static Task Run(Action action);
public static Task Run(Func<Task> function);
public static Task Run(Action action, CancellationToken cancellationToken);
public static Task Run(Func<Task> function, CancellationToken cancellationToken);
public static Task<TResult> Run<TResult>(Func<Task<TResult>> function);
public static Task<TResult> Run<TResult>(Func<TResult> function);
public static Task<TResult> Run<TResult>(Func<Task<TResult>> function, CancellationToken cancellationToken);
public static Task<TResult> Run<TResult>(Func<TResult> function, CancellationToken cancellationToken);
```

The generic ones will be eliminated because the compiler can't infer a type for them.  The ones without a `CancellationToken` parameter will also be eliminated because they don't have the proper parameter count.  That leaves the compiler choosing between. 

``` csharp
public static Task Run(Action action, CancellationToken cancellationToken);
public static Task Run(Func<Task> function, CancellationToken cancellationToken);
```

The lambda due to its infinite loop can convert to each delegate type.  The compiler considers the conversion to `Func<Task>` better though because it has a return type and `Action` does not (section 7.4.3.3 of 3.5 language spec).  Hence this overload is picked.  

Now if we look closely at this API the return type is a little off.  For every other case of `Func<X>` delegate the `Task.Run` API returns `Task<X>`.  With `Func<Task>` though it returns just `Task`.  It isn't doing this by taking advantage of the inheritance relationship between `Task<T>` and `Task` but instead it's calling `Unwrap` under the hood.  This creates a second `Task` which presents the original `Task<Task>` into a single item. 

So the quirk of the `Task` API is that there are two `Task` values here, not one.  The `Task<Task>` which is created to run the lambda is indeed "WaitingToRun / Running" but the `Task` which is returned is waiting on that to complete hence is "WaitingForActivation".  

Isn't overload resolution grand?  

[1] One other case being method bodies that unconditionally throw an exception.

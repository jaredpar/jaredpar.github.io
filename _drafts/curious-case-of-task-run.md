---
layout: post
title: The curious case of Task.Run not starting
tags: [c#]
---

Recently I was confused about the interaction between `Task` and `CancellationToken`.  In particular I couldn't remember if a `Task` which was already running was marked cancelled as soon as the associated `CancellationToken` was cancelled or if it waited until the `Task` completed. The documentation wasn't much help so I decided to write up a quick program to test out the behavior: 

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

```
WaitingForActivation
```

Say what?  A `Task` created with `Task.Run` should be started automatically, it should never be waiting for activation.  That's one of the advantages to this API.  

This behavior had me puzzled quite a bit.  Enough so that I ended up emailing [Stephen Toub](https://github.com/stephentoub) about it.  Between the two of us we were able to track the behavior down to a quick of both the C# compiler and the `Task` APIs.  

The C# quirk involves how the lambda conversion is processed.  In this case the compiler detects the lambda never returns because it has an infinite loop. The compiler allows lambdas that never return to convert to delegate of any return type that is otherwise compatible [^1].  Hence it can convert equally well to `Func<Task>` as it can to `Action`.  

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

The generic ones will be eliminated because the compiler can't infer a type for them.  The ones without a `CancellationToken` parameter will also be eliminated because they don't match the argument count.  That leaves the compiler choosing between. 

``` csharp
public static Task Run(Action action, CancellationToken cancellationToken);
public static Task Run(Func<Task> function, CancellationToken cancellationToken);
```

The lambda due to its infinite loop can convert to each delegate type.  The compiler considers the conversion to `Func<Task>` better though because it has a return type and `Action` does not [^2].  Hence this overload is picked.  

Now if we look closely at this API the return type is a little off.  Most of the other overloads that take a `Func<X>` delegate have a return type of `Task<X>`.  The `Func<Task>` overload though just returns `Task`.

It isn't doing this by taking advantage of the inheritance relationship between `Task<T>` and `Task` but instead it's calling [Unwrap](https://msdn.microsoft.com/en-us/library/dd780917%28v=vs.110%29.aspx?f=255&MSPPError=-2147217396) under the hood.  This creates a proxy `Task` which presents the original `Task<Task>` as single item. 

So the quirk of the `Task` API is that there are two `Task` values here, not one.  The first is the `Task<Task>` which is created to run the lambda is indeed "WaitingToRun / Running".  The second is the `Task` which is dependent upon the first and hence is "WaitingForActivation". 

To fix both of these I just needed to change the `Task.Run` call to pick the correct overload:

``` csharp 
Task t = Task.Run((Action)(() => { while(true); }), cts.Token);
```

Now I get the answer I originally wanted: WaitingToRun.  Cancelation is not prompt in this case.  

Isn't overload resolution grand?  

[^1]: One other case being method bodies that unconditionally throw an exception.
[^2]: Documented in section 7.4.3.3 of 3.5 language spec.

---
layout: post
title: Successful compilations can have errors
tags: [c#]
---

Errors are the mechanisms by which compilers communicate language syntax and semantic errors to users.  Good error error messages educate the user about the issue and ideally tells them how to correct it.  This is the ideal situation because it allows users to self correct their code.  Bad error messages though typically just state the problem, possibly crpytically, and are little better than the compiler spitting out `E_FAIL` with a line number.  

Producing a good message can be quite challinging and can take up a considerable amount of time when working on a new feature.  Like anything else it often comes down to difficult trade offs.  The information may be there in the code for a better message but getting to it may simply be too expensive.  

When I explain this to frustrated users it often leads to the following exchange:

> Them: This error message is terrible and misses the real problem.  Why doesn't it say "do x instead"? 
> Me: You're right it absolutely could say that but unfortunately calculating 'x' is quite expensive.
> Them: So? This is an error so the compilation is going to fail anyways, I'll pay an extra second for a better error here.

The problem here is the premise is simply incorrect: encontering an error doesn't necessarily mean that a compilation will fail.  It can actually produce loads of errors which are eventually discarded resulting in a successful compilation.  This happens as a side effect of how lambdas and overload resolution interact. 

Consider the following code, it produces at least one error during binding but will successfully compile:

``` csharp
void M(Action<int> action) { }
void M(Action<string> action) { } 

void Test()
{
    M(x => Console.WriteLine(x.Length));
}
```

The key here is that lambda expressions aren't by themselves assigned a type by the compiler.  Instead the compiler attemps to convert the lambda to a type based on how it is used [1].  If it's assigned to a local it uses the type of the local, if it's passed as an argument it uses the type of the parameter, etc ... 

In this case the lambda is used as an argument to a method that has multiple overloads.  Hence the compiler attempts to convert the single lambda to two different types: 

- `Action<int>`
- `Action<string>`

When the compiler considers `Action<int>` it will type `x` as `int`.  This will eventually lead to an error as `int` has no member `Length` and the compiler will consider the lambda to have no conversion to `Action<int>`.  When the compiler considers `Action<string>` though it will succeed because `x.Length` is a valid expression in that context.  Hence it considers the lambda to have a conversion to `Action<string>` and the overload `M(Action<string>)` is chosen as the winner. 

The error in this pattern is not just limited to member binding.  It can produce and discard virtually any error that occurs inside the body of a method.  

This means that the above code will compile but also produces errors that the compiler has to discard along the way.  Hence errors actually must be considered a part of the successful compilation path, not the unsuccessful one.  As such they must be calculated as effeciently as possible.  

Even if this weren't true and errors always represented a failed compilation they would still need to be calculated efficiently.  The reason why is IDEs, they have a vested interest in being able to display errors quickly to users. 

[1]: This is also why C# disallows `var x = () => { }`, neither the lambda nor the local have a type!

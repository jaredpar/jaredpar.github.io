---
layout: post
title: Successful compilations can have errors
tags: [c#]
---

Errors are the mechanism by which compilers communicate program errors to users. Good error messages educate the user about the issue and ideally tells them how to correct it.  This is the ideal situation because it allows users to self correct their code.  Bad error messages though typically just state the problem, possibly quite cryptically, and are little better than the compiler spitting out `E_FAIL` with a line number.  

A frequent piece of feedback from customers is an error message could be improved if the compiler could provide better information about the names and symbols used in the error.  For instance:

- Implement a better heuristic for guessing the overload the developer intended to use.
- Dig through all available namespaces to see if there is type that could match that unresolvable name.  
- Dig through all available namespaces to see if there is an matching extension method.
- etc ...

These are valid suggestions but require extra computation by the compiler.  In many cases this computation is much more expensive than customers anticipate due to the nature of the language and implementation details of the compiler.  When I explain this problem it often leads to the following exchange:

- Them: This error message is terrible and misses the real problem.  Why doesn't it say "do x instead"?
- Me: You're right it absolutely could say that but unfortunately calculating 'x' is quite expensive.
- Them: That's ok. This is an error so the compilation is going to fail anyways. I'll pay an extra second for a better error here.

The problem here is the premise is simply incorrect: encountering an error doesn't necessarily mean that a compilation will fail.  A compilation can actually encounter many errors which are eventually discarded leading to a successful compilation.

The most common reason for this behavior is a side effect of how lambdas and overload resolution interact. Consider the following code, it produces at least one error during compilation but will successfully compile:

``` csharp
void M(Action<int> action) { }
void M(Action<string> action) { }

void Test()
{
    M(x => Console.WriteLine(x.Length));
}
```

The key here is that lambda expressions don't have a type by default.  The compiler assigns them a type based on how the lambda expression is used [^1].  If it is assigned to a local it uses the type of the local, if it's passed as an argument it uses the type of the parameter, etc ...  In the case the lambda is incompatible with the type being assigned the compiler an error will occur.  For example:

``` csharp
Action<int> del = x => Console.WriteLine(x.Length);
```

The parameter and return types match here so the compiler attempts to bind the method body as if `x` were typed as `int`.  In doing so it will issue an error because `int` doesn't have a member named `Length`.  Hence `Action<int>` is not a suitable type for the lambda.  To determine this the compiler had to go through the effort of binding the entire lambda body.  It's the only way to verify the type is suitable for the lambda.

Now consider the example above where a lambda is passed to an overloaded method.  The compiler now has a pair of parameter types to consider: `Action<int>` and `Action<string>`.  To determine determine which overload should be used the compiler must consider if the lambda as each of the parameter types:  

- `Action<int>`: Error because `int` has no member `Length`.
- `Action<string>`: Success as `string` has a member `Length` which is a valid argument for `Console.WriteLine`.

The compiler will choose `M(Action<string>)` because it's the only valid overload.  Again though the only way the compiler could make this determination was to fully bind the lambda as `Action<int>` and determine it was invalid due to producing errors. These errors are not just limited to missing members, it can be virtually any error that occurs inside a method body.  

This is just one reason why error creation performance is an important issue for the compiler: it occurs even during successful compilations. Even if this weren't true and errors always represented a failed compilation they would still need to be calculated efficiently.  Consider for example environments like Visual Studio that host the compiler.  They have a vested interest in displaying errors efficiently.  

[^1]: This is also why C# disallows `var x = () => { }`, neither the lambda nor the local have a type!

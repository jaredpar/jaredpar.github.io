---
layout: post
title: Warning on lower case type names in C# 11
tags: [c#, language design]
---

C# 11 is the next version of C# coming in .NET 7, and it is introducing a warning wave that issues a warning when a type is declared with all lower-case letters. This is being done so that in the future the language can begin moving away from conditional keywords and instead use full on keywords instead. The warning is alerting customers to types that may become keywords in future versions.

C# has a strong compatibility guarantee and with that, it has forced us to unnecessarily complicate the language in the past in a few areas. The reason being that whenever we introduce a new keyword into the language it must be a conditional keyword. This means that the C# language must consider both the case when the identifier is used as a keyword and when it's used as a type

The classic case of this is `var`. Even though 99.999% of the time `var` means that it's an inferred type the language has to consider the case where the user defined a type called `var`. This is case is on the level of "annoying to compiler developers". It doesn't really hamper the language, it just makes compiler developer lives harder. 

There are cases that are more impactful though. A frequent request we've gotten over the years is `async` / `await` is adding unnecessary ceremony to the language. Essentially:

> Why do I need `async` on the method at all? After all I put `await x` in the body so clearly this is an `async` method. Let's remove `async` and make the language simpler

The problem is that statement isn't considering the case where the user has `class await` in their code. At that point `await x` is a variable declaration, not an operation. That is why `async` is necesssary, it serves to tell the compiler to ignore any `class await` in the code and treat `await`as an operator. This is a case where compat has served to make the language more complicated to support obscure scenarios. 

When doing `record` though we hit a bit of a breaking point. This is not a new feature and there is plenty of prior art across the language landscape and that prior art called for a concise declaration syntax. Consider that Java had the following syntax:

```java
record Name(string First, string Last) { }
```

The compatibility guidelines of C# though forced us to consider the case that `record` could be a type at which point the above is ambiguous. It could be a type, method signature, lambda, etc. This is a case where there was no out here because it was a hard ambiguity in the language. After a lot of debate, we made the call in C# 9 to say that `record` was a keyword when used in a type position. That gave us the concise syntax we desired at the expense of breaking users who had `class record` in their code. This break was conditioned on `langversion:9` though so users had to opt into the break. Even so we held our breath a bit when we released it and ... no one cared. We made the language simpler, and we lost almost nothing.

There are many other places where we've known this will be a problem for future features. Hence rather than take one hit at a time when we release new C# language versions we took the broader view of allowing lower case type names is hampering language evolution. Let's issue a blanket warning now so users are aware of the potential for these to become keywords in future versions of the language.

That is the [motivation](https://github.com/dotnet/roslyn/issues/56653) for warning here: language simplicity 



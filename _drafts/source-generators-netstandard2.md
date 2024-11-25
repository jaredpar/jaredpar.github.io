---
layout: post
title: Source Generators and netstandard2.0
---

Source generators are a powerful framework for generating code at build time in C#. They run as plugins to the C# compiler, have full access to the syntax tree, references, options, etc ... and can generate new source files that are compiled as part of the build. As a plugin though it means that generators, and analyzers, need to be runnable anywhere the compiler can run and this leads to a limitation that's often frustrating to developers: they must target netstandard2.0.

This limitation exists because the compiler runs on virtually every .NET runtime in existence: .NET Framework, .NET Core, Mono, etc ... Even .NET SDK based projects will use a .NET Framework based C# compiler when built through `msbuild` instead of `dotnet build`.

There is a tendancy for this to be viewed as a self imposed problem. Microsoft owns these compilers, just do the work to convert them to .NET Core and that would free up generators. And there is a bit of truth to that. There are certainly technical and non-technical challenges to moving these to .NET Core but they are solvable.

That misses the bigger picture though as the compiler also exists as a library. This means it, and generators, can be hosted in other products. There are many such products out there including Visual Studio, VS Code DevKit, Omnisharp, CodeQL, source.dot.net, compiler logs, etc ... Many of these are third party products far outside the control of the .NET team. The ability for generators to target .NET core is not just a matter of moving the compiler to .NET Core but also ensuring that all of these products can host the compiler on .NET Core as well.

This all means though that the question of "when will generators be able to target .NET core" is better stated as:

> When will we stop shipping the compiler libraries with a netstandard2.0 TFM?

The answer to that is probably many years into the future. There are still a lot of customers out there that host the compiler on .NET Framework. Migrating them to .NET core would take a concerted effort over several releases and there isn't a lot of incentive for this. That means for the forseable future generators need to consider that they will be run on .NET Framework, possibly in products they aren't even aware of.

That all being said, there is good news on this front. It is likely that by the time .NET 10 ships .NET SDK based projects will always be built using a .NET Core based compiler. This means even when `msbuild` is used the compiler from the .NET SDK will still be used for build. Generator authors who only care about .NET Core can now make reasoned decisions about moving their generators to .NET Core. If they are comfortable with the trade offs of working in core scenarios (build, Visual Studio and VS Code) but not working in other scenarios they could decide to target .NET Core. But a future where they can target .NET Core with no trade offs is still a long way off.

Note: this post is written about source generators but everything in it applies to analyzers as well. Generators though are the more frequent source of questions on this topic.

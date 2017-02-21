---
layout: post
title: Using assembly attributes to control code behavior
tags: [misc]
---

**It has the danger of letting a simple infrastructure bug impact the threading model of the entire program.**

## 

Not a fan of the [assembly: ConfigureAwait(false)] solution.  Such a feature prevents a developer from casually reading code and understanding what it is doing.

The meaning of `await` becomes conditional on an attribute that may or may not exist in the compilation the file is included in.  This is an increasingly worse situation in .NET development where multi-targeting comes into play.  There a code file may be included in many different compilations any of which may, or may not include such an attribute.  

Really the only way to determine how an `await` is to look at the code post compilation.  The resulting DLL / EXE can be inspected with ILSpy.  There it's very straight forward to look for the `[ConfigureAwait(true / false)]` attribute.  That's a pretty terrible way to go about understanding the code though. 

The `ConfigureAwait` discussion is a specific instance of a more general problem: using global options to control the way in which code is compiled.  The global options can come in the form of a compiler switch, assembly attribute, etc ...  Essentially using any information which isn't a part of the code file being compiled.  

Any such global option inhibits the ability of developers to understand how their code is working.  The code being authored can have the meaning changed without any visual queues to the developer.  The option is essentially spooky action at a distance.

##

This is not a black and white issue though, instead it's a spectrum of features that affect the ability for developers to understand their code.  The axis of the spectrum are how far does the developer need to look to understand the change and how broad of an impact can a particular change in the option have on the program.

Features like `var` exist in the middle of the spectrum here.  When used aggressively it can be hard for a developer to understand the code due to the inability to understand the types involved:

``` c# 
var x = SomeMethodName();
```

Likewise reviewing a change to the return type of `SomeMethodName` is hard to guage because it can impact an unknown number of locations where `var` is used.  ** this is weak ** 

A global option / attribute exists on the far end of the scale.  It can be inserted in any number of places in the build process and can change an untold number of statements in the program.  It has the danger of letting a simple infrastructure bug impact the threading model of the entire program. 

## 

For all the success of the .NET async-based programming model, there is one frequent source of developer dissatisfaction: having to constantly type out `ConfigureAwait(false)`.  

The default behavior of an awaited `Task` is to resume on the context (or thread) where the original `await` occurred.  This is great for UI programs where the majority of the controls have thread affinity.  Resuming on any other thread would cause exceptions when the controls were used.

This default behavior though is often inconvenient for library oriented code.  Such code is less likely to have objects with thread affinity and is often designed to run on a number of threads.  The overhead involved with ensuring code resumes on the same thread is a performance burden here that library authors would rather avoid.  Hence their code bases are literred with verbose calls to `ConfigureAwait(false)`. 






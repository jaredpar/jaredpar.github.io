---
layout: post
title: Successful Compilations Can Have Errors
---

The last few years I've been working on a research language used by a lot of high quality developers

Errors are the way compilers attempt to communicate proper language syntax and semantics to users.  Languages are complex and getting an error message that perfectly conveys the problem is tricky, especially when guessing problems like overload resolution come into play.  

Bad errors ocassionally lead to exchanges like following 

> Them: This error message is terrible and misses the real error.  Why doesn't it say "do x instead". 
> Me: You're right it absolutely could say that but unfortunately calculating 'x' is quite expensive
> Them: So? This is an error so the compilation is going to fail anyways, I'll pay an extra second for a better error

The idea that an error leads to a compilation failure is simply not true.  Programs which copmile successfully often produce errors as a part of the copmilation process.

Overload resoltion, lambdas, etc ...

This is why even error message calcultion needs to be efficient.

Lets not forget IDEs ...


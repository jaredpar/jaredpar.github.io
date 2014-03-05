---
layout: post
---
I published a .Net utility library on [Code Gallery](http://code.msdn.microsoft.com) today called [BclExtras](http://code.msdn.microsoft.com/BclExtras). It's a set of classes meant to be used in addition to the standard .Net base class libraries (BCL).  The main focuses of the library are functional programming, multi-threading, LINQ extensions, unit testing and API's designed to support type inference.  

This project evolved from various classes and constructs I was using in personal projects. For the last year or so I've kept as a separate tested library. It started out with a lot of multi-threaded code constructs but lately is leaning to a lot of functional style API's and collections.

The library includes source and binaries for .Net 2.0 and .Net 3.5. The .Net 2.0 version of the library includes many constructs added in 3.5 that don't rely on any 2.0SP1 CLR features. Examples are Func<T>, Action<T>, the Extension attribute and a subset of the LINQ Enumerable class. It allows for most LINQ expressions in a 2.0 targeted application. These types are removed in the 3.5 version to avoid conflicts with types in System.Core.

I've previously released this library under the name [RantPack](http://code.msdn.microsoft.com/RantPack). It originally started out as personal utility library of mine and hence ended up with the somewhat obscure name. But, besides to me, RantPack doesn't really convey a useful meaning. So I decided to give it a more meaningful name for the general population.


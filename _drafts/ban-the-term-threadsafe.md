---
layout: post
title: We should ban the phrase "thread safe"
---
There few are statements in programming that make me shudder more than 

> This type is thread safe

Seeing this is like nails on a chalk board.  I physically cringe whenever I read it in an email or here it out loud.  The reason is that this phrase is attempting to describe the properties of a type when accessed from multiple threads but absolutely fails to do so.  

The phrase *thread safe* makes it sound like thread safety is yes / no property of a type.  This is simply not the case as there are a wide variety of threading related properties which define a type.  Here is just a small sampling.

Data Race Free
===
A type which is data race free will never corrupt its internal state no matter how many threads are reading from and writing to it.  Sharing such a type between threads is safe in that the internal data structures will never be corrupted.  However using such a type is still fraught with problems.  For example 

```csharp
static object GetFirstOrDefault(ArrayList synchronizedList) { 
  if (synchronizedList.Count > 0) {
    return synchronizedList[0];
  }

  return null;
}
```

For the curious I already covered this problem in detail in a [previous post]({% post_url 2009-02-11-why-are-thread-safe-collections-so-hard %}) 

Examples of this include Java vectors, .Net 1.0 [synchronized collections](http://msdn.microsoft.com/en-us/library/3azh197k(v=vs.110).aspx), and .Net 4.0 [concurrent collections](http://msdn.microsoft.com/en-us/library/dd381779(v=vs.110).aspx).  

Multiple Reader, Single Writer
===

Not Even Read Safe 
===

Splay Trees

Immutable Types
===
This is the one class of types to which *thread safe* actually can be validly applied.  A type which never changes satisfies any rational expectation a developer has safe use amongst threads.  Seemingly random operations like thread ordering have no effect on the outcome of operations on an immutalbe type which is 

But if you have an immutable type calling it as such is much more descriptive than *thread safe*.  Don't bother with ambiguous terminology when far more descriptive alternatives exist. 

Going forward I encourage you to be active in removing this ambiguity.  If someone makes a claim of *thread safety* for their types call them out.  Ask them to enumerate specifically which properties of the type are thread safe and what guarantees it provides.  And most importantly, once they enumerate the details make sure it is documented in the type itself and not just an email.  

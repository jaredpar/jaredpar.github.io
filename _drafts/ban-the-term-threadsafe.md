---
layout: post
title: "We should ban the phrase "
published: true
---

There few are phrases in programming that make me shudder more than 

> This type is thread safe

Reading this phrase is like hearing nails on a chalk board.  I often physically cringe as a result.  The reason why is this phrase is incredibly misleading.  It's attempting to describe the properties of a type when accessed from multiple threads but utterly failing to do so.  

The phrase *thread safe* makes it sound like thread safety is on / off property of a type.  Nothing could be further from the truth.  There is a wide variety of multi-threaded usage scenarios for types that simply cannot be decribed in a binary fashion.  Here is a small sampling of these scenarios 

Data Race Free
===
A type which is data race free will never corrupt its internal state no matter how many threads are reading from and writing to it.  Sharing such a type between threads is safe in that the internal data structures will never be corrupted.  A data race free list will never have a count different than the actual number of elements stored inside it. 

However using such a type is still fraught with problems.  For example here is a bad sample using a synchronized version of [ArrayList](http://msdn.microsoft.com/en-us/library/vstudio/system.collections.arraylist)

```csharp
static object GetFirstOrDefault(ArrayList synchronizedList) { 
  if (synchronizedList.Count > 0) {
    return synchronizedList[0];
  }

  return null;
}
```

None of the individual statements here are an incorrect usage of synchronizedList yet the code itself is wrong.  It's possible for any number of threads to execute in between the initial `if` block and the `return` statement.  Any of which could clear the list [^1]. 

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

[1^]: For the curious I already covered this problem in detail in a [previous post]({% post_url 2009-02-11-why-are-thread-safe-collections-so-hard %}) 

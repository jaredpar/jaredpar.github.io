---
layout: post
title: "We should ban the phrase "
published: true
---

There few are phrases in programming that make me shudder more than 

> This type is thread safe

Reading this phrase is like hearing nails on a chalk board.  I often physically cringe as a result. 

The phrase *thread safe* makes it sound like thread safety is on / off property of a type.  Nothing could be further from the truth.  There is a wide variety of multi-threaded usage scenarios for types that simply cannot be decribed in a binary fashion.  

A much better way to describe the thread safety of a type is to enumerate the scenarios in which the type can and can't be used.  Giving users concrete information on how the type will behave in specific circumstances gives them a much better chance of correctly using the type in their own programs.  Once the scenarios are enumerated you'll often find these types fall into exitsing well known patterns which the user is more likely to have experience with.  

Here is a non-exhausting sampling of the most common multithreaded patterns I  encounter.  

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
This class of types can be safely read from mulitple threads or written to by any given thread.  However these operations cannot be done at the same time or the data structure will possibly corrupt its internal state.  

This pattern allows for useful operations like parallel projection (projecting the contents of a list in multiple threads).  

In my experience this is the most common pattern for types because it is the natural default.  Unless a type has some manner of thread affinity or read operations which mutate internal structure it will fit this pattern.  For example the .Net BCLR collections all fit this pattern 

Thread Affinity
===
Thread affinitized types can only be safely accessed from a specific thread in the program.  Any attempt to access instances of the type from code executing on a different thread is an error.  Such code must somehow transfer execution to the correct thread in order to safely inspect the object.

This pattern is probably most common in UI frameworks.  It is in fact the source of one of the most frequently asked questions on [stackoverflow](http://stackoverflow.com).  

> Why does an exception get thrown when I change a property on my control? 

```csharp
var worker = new BackgroundWorker();
worker.DoWork += DoWork;

private void DoWork(object sender, DoWorkEventArgs e) {
  /* background caclulation */
  _theLabel.Text = theResult;
}
```

All WinForm controls are affinitized to the UI thread.  Any attempt to modify them from another thread will be met with an exception.  In this case the BackgroundWorker callback executes on a different thread and hence this is a violation of the types threading contract.  

Lucikly Winform types are one of the few types that enforce their thread safety contract at runtime. 

Not Even Read Safe 
===


Splay Trees

External Synchronization
===
Most dangerous form 

Immutable Types
===
This is the one class of types to which *thread safe* actually can be validly applied.  A type which never changes satisfies any rational expectation a developer has safe use amongst threads.  Seemingly random operations like thread ordering have no effect on the outcome of operations on an immutalbe type which is 

But if you have an immutable type calling it as such is much more descriptive than *thread safe*.  Don't bother with ambiguous terminology when far more descriptive alternatives exist. 

Don't ever let another program get away with saying *thread safe*.  Call out this inaccurate description of a type and ask them to enumerate specifically the scenarios in which this type can be used safely from multiple threads.  What specific guarantees does it provide and how can users get it wrong?  And most importantly, once they enumerate the details make sure it is documented in the type itself and not just an email.

[1^]: For the curious I already covered this problem in detail in a [previous post]({% post_url 2009-02-11-why-are-thread-safe-collections-so-hard %}) 

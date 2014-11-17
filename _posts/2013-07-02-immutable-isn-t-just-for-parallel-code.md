---
layout: post
title: Immutable isn't just for parallel code
tags: [immutable]
---
For the last 6 months the BCL team has been hard at work shipping an out of band release of immutable collections for .Net.  Most recently delivering an efficient implementation of ImmutableArray<T>

> <http://blogs.msdn.com/b/dotnet/archive/2013/06/24/please-welcome-immutablearray.aspx>

Unfortunately with every announcement around these collections I keep seeing the following going past in my twitter feed.

> That looks neat.  Next time I'm writing parallel code I'm going to try that out.

No, no no!!!  Immutable types are not just for parallel code.  They are very useful in even single threaded applications.  Developers are missing out by thinking of them as a parallel only construct.  Any time you want to enforce that the contents of a collection never change you should consider an immutable type.

**The Provider**

Consider the case of an object which provides a collection to callers where the contents never change.  Something like Assembly.Modules.  A type like Assembly must be robust in the face of misuse by any caller and always present the same set of Module values.   Given this constraint what type should it use though for the property?

It can't do something as simple as using a List<Module> with a similarly typed backing field.  Returning such a value would allow a devious caller to clear the list and spoil the results for everyone else.   It cannot even store a List<T> internally and return an IEnumerable<T> as anyone could just come along and down cast to List<T> and clear the collection.

``` csharp
Assembly assembly = ...;
// Evil laugh
((List<Module>)assembly.Modules).Clear(); 
```

Instead it chooses to be robust by returning a freshly allocated array on every single call to Modules [^1].  This works but is a very wasteful process and results in many unnecessary allocations.

If this API were being designed today this would be a perfect candidate for using ImmutableArray<T>.  This value can be safely stored and returned with no fear of the caller deviously mutating the result.  There is simply no way of doing so.

**The Consumer**

Now consider the case of the consumer who wants to store a collection of Modules instances and do multiple lazy independent calculations on them.  In order for the different calculations to be correct they need to ensure the collection of Module instances don't change from operation to operation.  Hence they have to make a decision when storing the collection in the constructor

``` csharp
class Container {
   IEnumerable<Module> m_modules;

   public Container(IEnumerable<Module> modules) { 
     // Do I trust my caller' 
     m_modules = modules;
   }
}
```

The constructor can choose to do one of the following

  1. Create a private copy of the input collection that it doesn't mutate
  2. Create no copy and hope that the caller never mutates the input collection

The first option is wasteful and the second is just a bug waiting to happen a year from now when someone decides to reuse a List<Module> for another purpose.  With immutable types the container has a much better third option: demand a collection that never changes

``` csharp
class Container {
   ImmutableArray<Module> m_modules;

   public Container(ImmutableArray<Module> modules) { 
     // Trust no one 
     m_modules = modules;
   }
}
```

The callee has now forcefully stated to the caller exactly what type of data it expects.  It no longer has to make a wasteful copy or hope for good behavior.  True this may force the caller to create an immutable copy of the value it holds.  It's also just as likely that the caller will be in a position to provide the collection without any copies.  If it takes the collection as input it can simply pass along the requirement in its parameter list.  Or if it is the original creator of the collection it can do so as an ImmutableArray<Module> from the start and avoid the extra copy altogether.  Over time, code bases which are assertive about using immutable collections will see a decrease in allocations because they will feel more comfortable with sharing data between independent components.

This is just a small sample of cases where immutable collections are useful in day to day code.  The more you use them the more uses you will find for them.  At some point you may even find yourself asking the following question when writing up a type

> Do I actually **need** to mutate this collection after I finish building it?

Generally speaking the answer to this is no.  And this is why you should be using immutable types.

[^1]: If you dig deep into the implementation you'll find it's actually a fresh array of RuntimeModule[].  So even though they allocate a new array on every call you can't safely write Module instances into it unless they happen to be instances of RuntimeModule.  So wasteful!  

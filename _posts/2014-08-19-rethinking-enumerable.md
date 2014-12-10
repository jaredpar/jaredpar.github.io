---
layout: post
title: Rethinking IEnumerable<T> 
tags: framework
---

The .Net enumeration story based on `IEnumerable<T>` is a very succesful pattern.  It's the backbone of many different language and framework features including `foreach`, LINQ, iterators, etc ...  And yet when switching between C++ and C# and I'm often frustrated by its inefficiencs and quirks: 

* Accessing a single value requires 2 interface invocations: MoveNext and Current.  Interface method invocation has [extra overhead](http://msdn.microsoft.com/en-us/magazine/cc163791.aspx#S12) associated with it.  Why pay that price twice instead of using a single method call?
* It forces the allocation of a `IEnumerable<T>` value on the heap even when the enumerator could be implemented as a `struct`.  Allocations in .Net are cheap not free and it's frustrating to have one on such a core path. 
* The legacy of pre-generics .Net forces type safe collections to eventually implement the non-generic `IEnumerable`, `IEnumerator` and even `IDisposable`.  I can't remember the last time I actually used one of these and yet I have to write this boiler plate code every time I author a new collection.  
* Many collections, like `List<T>`, implement pattern based enumeration in part to avoid the above inefficiencies [^1]. This is more code to write, test and maintain yet really doesn't add any new features.  At the same time it also complicates the ability of the developers to understand the mechanisms behind a given `foreach` block.  

Recently as an experiment I decided to sit down and explore a new design for `IEnumerable<T>` which addressed these issues.  In particular it had the following goals: 

* Use a single method call to advance the enumeration and access the next value 
* Use strongly typed generics
* Do not force an allocation for the enumerator type
* Have a single code path for enumeration 
* Dispose of all the legacy baggage [^2]

After some tinkering I settled on the following design: 

``` charp
public interface IEnumerable<TElement, TEnumerator>
{
  TEnumerator Start { get; } 
  bool TryGetNext(ref TEnumerator enumerator, out TElement value);
}
```

The most visible change here is the elimination of `IEnumerator<T>` in favor of an enumerator type parameter.  This eliminates the forced allocation of enumerators and allows types like `List<T>` to use a more natural enumerator type like `int`.  

The real advantage in this pattern is that it greatly simplifies the code necessary to implement enumerable:

``` csharp
class MyList<T> : IEnumerable<T, int>
{
  T[] _array;
  
  public int Start 
  { 
    get { return 0; } 
  }
  
  public bool TryGetNext(ref int index, out T value)
  {
    if (index >= Count) { 
      value = default(T);
      return false;
    }
    
    value = _array[index++];
    return true;
  }
}
```

This implementation is free from all of the boiler plate code necessary to implement .Net `IEnumerable<T>`.  Instead it focuses on the actual code necessary to enumerate values.  The full example of .Net enumeration is included at the bottom of this post.  The code difference is staggering.  

The code generation for a `foreach` over the new pattern is the following:

``` csharp
void M<TElement, TEnumerator>(IEnumerable<TElement, TEnumerator> enumerable)
{
  // Developer types 
  foreach (TElement current in enumerable) {
    // Loop body
  }
  
  // Compiler emits 
  TElement current;
  TEnumerator e = enumerable.Start;
  while (enumerable.TryGetNext(ref e, out current)) {
    // Loop body 
  }
}
```

This enumeration pattern for `MyList<T>` will now be consistent no matter the context in which it is enumerated: through `MyList<T>` or `IEnumerable<T>`.  The enumerator type will now always be an `int`, it will always execute the same code path and this is the only enumeration code path to test.  

The downside to this approach is that it makes the consumption of enumeration in generics more complicated: all methods and types now require 2 type parameters instead of 1.  For advanced developers this isn't a significant overhead but for the average .Net developer it's a big increase in complexity.  

The biggest problem though using this in practice is that it doesn't work with existing `foreach` syntax.  Hence all loops needed to be typed out by hand and the actual looping pattern is not a great pattern for humans to be dealing with.  That would obviously go away if this was a first class language construct.  

Overall I'm pretty happy with this design though. Maybe I'll take a stab at prototyping Roslyn support for this feature at some point to get my `foreach` problems solved.  

As promised before, this is what the `MyList<T>` implementation of .Net `IEnumerable<T>` would look like (55 lines of code vs. 19 for the new pattern).  

```csharp
// Old Enumeration Pattern 
class MyList<T> : IEnumerable<T>
{
  T[] _array;

  internal struct Enumerator : IEnumerator<T>
  {
    int _index;
    MyList<T> _list;

    internal Enumerator(MyList<T> list)
    {
      _list = list;
      _index = 0;
    }

    public T Current
    {
      get { return _list._array[_index]; }
    }

    public void Dispose()
    {

    }

    object System.Collections.IEnumerator.Current
    {
      get { return Current; }
    }

    public bool MoveNext()
    {
      if (_index + 1 < _list._array.Length)
      {
          _index++;
          return true;
      }

      return false;
    }

    public void Reset()
    {
      _index = 0;
    }
  }

  public IEnumerator<T> GetEnumerator()
  {
    return new Enumerator();
  }

  System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
  {
    return new Enumerator();
  }
}
```


[^1]: In the pre-generics world of .Net pattern based enumeration also had the added benefit of type safe enumeration 
[^2]: Eliminating legacy is rarely a reality but it's fun to think about

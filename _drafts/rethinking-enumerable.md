---
layout: post
title: Rethinking IEnumerable<T> 
---

The .Net enumeration story based on `IEnumerable<T>` is a very succesful pattern.  It's the backbone of many different language and framework features including `foreach`, LINQ, iterators, etc ...  And yet when switching between C++ and C# and I'm often frustrated by its inefficiencs and quirks: 

1. Accessing a single value requires 2 interface invocations: MoveNext and Current.  Why isn't this just a single method call in the form of TryGetNext? 
2. It forces the allocation of a `IEnumerable<T>` even when the enumerator could be implemented as a `struct`.  Allocations in .Net are cheap not free and it's frustrating to have one on such a core path. 
3. Many collections, like `List<T>`, implement pattern based enumeration in part to avoid the inefficiencies of #1 and #2 [^1]. This is more code to write, test and maintain yet really doesn't add any new features. 
4. The legacy of pre-generics .Net forces type safe collections to still implement the non-generic `IEnumerable`, `IEnumerator` and `IDisposable`.  I can't remember the last time I actually used one of these. 

Recently as an experiment I decided to sit down and explore a new design for `IEnumerable<T>` which addressed these issues and came up with the following: 


``` csharp
public interface IEnumerable<TElement, TEnumerator>
{
  TEnumerator Start { get; } 
  bool TryGetNext(ref TEnumerator enumerator, out TValue value);
}
```

This design has several advantages:

1. 

For instance the enumeration of a list style type is vastly simplified:

``` csharp
class MyList<T> : IEnumerator<T, int>
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

The enumeration pattern for `MyList<T>` will now be consistent no matter the context in which it is enumerated: through `MyList<T>` or `IEnumerable<T>`.  The enumerator type will now always be an `int`.  



[^1]: In the pre-generics world of .Net pattern based enumeration also had the added benefit of type safe enumeration 

---
layout: post
title: Rethinking IEnumerable<T> 
---

The `foreach / IEnumerable<T>` pattern in C# is very succesful.  But when switching between C++ and C# I'm often frustrated by the inefficiencs and quirks of `IEnumerable<T>`: 

1. Accessing a single value requires 2 interface invocations: MoveNext and Current.  Why isn't this just combined into a single TryGet call?  
2. It forces the allocation of a `IEnumerable<T>` even when the enumerator could be implemented as a `struct`.  Allocations in .Net are cheap but not free and it's frustrating to have on on such a core path. 
3. Many collections, like `List<T>`, implement pattern based enumeration to avoid the inefficiencies of #1 and #2 [^1]. This is yet another code path to test and maintain.  
4. The legacy of pre-generics .Net forces type safe collections to still implement the non-generic `IEnumerable`, `IEnumerator` and `IDisposable` 



One item which continually comes up when working on making C# more efficient is `IEnumerable<T>`.  



Lately I've been playing around with the following design:

``` csharp
interface IEnumerable<TElement, TEnumerator>
{
  TEnumerator Start { get; } 
  
  bool TryGetNext(ref TEnumerator enumerator, out TValue value);
}
```

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

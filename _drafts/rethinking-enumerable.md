---
layout: post
title: Rethinking IEnumerable<T> 
---

One item which continually comes up when working on making C# more efficient is `IEnumerable<T>`.  

It includes several inefficiencies

1. It forces an allocation whenever an `IEnumerable<T>` is enumerated even if the enumerator could be implemented as a `struct`
2. Collection definitions need to define a second type to implement `IEnumerator<T>` 
3. Efficient collections have to implement the pattern based version of enumeration to avoid the allocation in common paths.  

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





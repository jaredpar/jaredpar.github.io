---
layout: post
title: Rethinking IEnumerable<T> 
---

The .Net enumeration story based on `IEnumerable<T>` is a very succesful pattern.  It's the backbone of many different language and framework features including `foreach`, LINQ, iterators, etc ...  And yet when switching between C++ and C# and I'm often frustrated by its inefficiencs and quirks: 

1. Accessing a single value requires 2 interface invocations: MoveNext and Current.  Why isn't this just a single method call in the form of TryGetNext? 
2. It forces the allocation of a `IEnumerable<T>` even when the enumerator could be implemented as a `struct`.  Allocations in .Net are cheap not free and it's frustrating to have one on such a core path. 
3. The legacy of pre-generics .Net forces type safe collections to still implement the non-generic `IEnumerable`, `IEnumerator` and `IDisposable`.  I can't remember the last time I actually used one of these. 
4. Many collections, like `List<T>`, implement pattern based enumeration in part to avoid the above inefficiencies [^1]. This is more code to write, test and maintain yet really doesn't add any new features.  At the same time it also complicates the ability of the developers to understand the mechanisms behind a given `foreach` block.  


Recently as an experiment I decided to sit down and explore a new design for `IEnumerable<T>` to address these issues and came up with the following: 

``` csharp
public interface IEnumerable<TElement, TEnumerator>
{
  TEnumerator Start { get; } 
  bool TryGetNext(ref TEnumerator enumerator, out TElement value);
}
```

The most visible change here is the elimination of `IEnumerator<T>` in favor of an enumerator type parameter.  This eliminates the interface indirections and unnecessary allocations.  Types like `List<T>` can use a more natural enumerator type like `int`.  This pattern greatly simplifies the code necessary to implement enumeration 

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

This implementation is free from all of the boiler plate code necessary to implement .Net `IEnumerable<T>` (the full example of which is at the bottom of the post).  Instead it focuses on the actual code necessary to enumerate the type. 

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

The enumeration pattern for `MyList<T>` will now be consistent no matter the context in which it is enumerated: through `MyList<T>` or `IEnumerable<T>`.  The enumerator type will now always be an `int` and it will always execute the same code path.  


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

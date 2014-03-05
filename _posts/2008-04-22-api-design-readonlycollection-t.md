---
layout: post
---
I am a huge fan of read only/immutable collections and data.  Hopefully the increased exposure through the blogosphere alerted users to the advantages of this type of programming for the appropriate scenarios.  I wanted to discuss [ReadOnlyCollection<T>](http://msdn2.microsoft.com/en- us/library/ms132474.aspx) in case devs looking around in the BCL discover it and assume it's immutable.  There are two details of this class which cause gotchas and design issues for consumers who assume it is immutable.  

### It implements IList<T>

[IList<T>](http://msdn2.microsoft.com/en-us/library/5y536ey6.aspx) is a interface describing mutable collection types which support indexing.  ReadOnlyCollection is designed to be read only and cannot fulfill this contract.  Therfore every mutable function will throw an exception.  IMHO this is not the best design because it is implementing a contract it won't every fullfill.  This has the effect of turning what should be a compile time error into a runtime exception (passing a non-mutable collection to an API expecting a mutable collection).

Unfortunately there is not a good interface to implement.  The indexable interfaces are all representative of mutable collection types.  It would be nice to add an immutable/read only interface which can be safely implemented.  
    
{% highlight csharp %}
interface IReadOnlyList<T> : IEnumerable<T>
{
    T this[int index] { get; }
    int Count { get; }
    int IndexOf(T value);
    bool Contains(T item);
    void CopyTo(T[] array, int arrayIndex);
}
{% endhighlight %}

Ideally this would be called IImmutableList<T> but I'm having trouble getting over the double I, double M pattern to start the name.  Perhaps IPersistentList.

### It's not deeply ReadOnly

ReadOnlyCollection<T> is a read only facade on top of mutable collection.  Read only data should be just that, read only.  This means calling methods directly on the class produce the same result every single time.  However because it uses a mutable backing store this is not true and can cause gotchas along the road.

Take the following sample which uses a ReadOnlyCollection to wrap a List.

{% highlight csharp %}
var list = new List<int>();
list.AddRange(Enumerable.Range(1, 10));

var roList = new ReadOnlyCollection<int>(list);
Console.WriteLine(roList.Count);    // Outputs: 10
list.Add(42);
Console.WriteLine(roList.Count);    // Outputs: 11
{% endhighlight %}

There are ways to avoid this problem with ReadOnlyCollectionn.  The simplest
is to make sure you pass a copy of your list into the constructor.

{% highlight csharp %}
var roList2 = new ReadOnlyCollection<int>(new List<int>(list));
{% endhighlight %}


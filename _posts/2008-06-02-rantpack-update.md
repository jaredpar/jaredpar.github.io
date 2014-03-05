---
layout: post
---
I released a new version of RantPack today. Mostly this is a bug fix release with a couple of minor new features.

[https://code.msdn.microsoft.com/Release/ProjectReleases.aspx?ProjectName=RantPack&ReleaseId=1119](https://code.msdn.microsoft.com/Release/ProjectReleases.a spx?ProjectName=RantPack&ReleaseId=1119)

Features

  * Added a way to shim Immutable collections to non-immutable interfaces to increase the level of interoperability. The collections are still immutable and throw an exception whenever one of the mutable APIs are called. However if the collection is used in an immutable fashion, such as data binding, CollectionUtility.Create* can be used to quickly create a wrapper
    
{% highlight csharp %}
    var q = ImmutableStack<int>.Empty;
    CollectionUtility.GetRangeCount(1, 10).ForEach(x => q = q.Push(x));
    ICollection<int> list = CollectionUtility.CreateICollection(q);
    
    var m = ImmutableAvlTree<int, string>.Empty;
    CollectionUtility.GetRangeCount(1, 10).ForEach(x => m = m.Add(x, x.ToString()));
    IDictionary<int, string> map = CollectionUtility.CreateIDictionary(m);
{% endhighlight %}

  * Added an immutable queue named ImmutableQueue
  * Added more overloads to Immutable*.Create to allow more interoperability with BCL data structures.

Bugs

  * MutableTuple.GetHashCode() violated the contract for Object.GetHashCode() by allowing updates to mutate the hash code


---
layout: post
---
[IComparable(Of T)](http://msdn2.microsoft.com/en-us/library/4d7sx9hd.aspx) is an interface saying "I can compare myself to other objects of the same type".  And [IComparer(Of T)](http://msdn2.microsoft.com/en-us/library/8ehhxeaf.aspx) is an interface saying "I can compare two objects of this type.". Often API's which need to perform comparisons will take an instance of IComparer(Of T) instead of IComparable(Of T).

Doing the opposite is limiting in a few ways. The first is it locks developers into the behavior defined by the type author essentially preventing them from deciding to compare in a different way. The second is if the type author didn't didn't implement IComparable(Of T), we must define a wrapper class that does. This is even more awkward because collections now contain instances of the wrapper. Also there is one wrapper overhead per instance in the collection.

Now back to the original problem, we have a type which implements IComparable(Of T) but don't have an IComparer(Of T) wrapper class. Luckily the .Net Framework provides a solution. Comparer(Of T).Default. It provides a quick IComparer(Of T) wrapper that automatically delegates to IComparable(Of T) if the type defines it.

Example usage: [Previously]({% post_url 2008-03-31-missing-api-list-of-t-binaryinsert %}) we defined a BinaryInsert method for List(Of T). It required an explicit IComparer(Of T) be passed even for simple types like Int32. We can fix this by using the Comparer(Of T) class.

    
{% highlight vbnet %}
<Extension()> _
Public Sub BinaryInsert(Of T)(ByVal list As List(Of T), ByVal value As T)
    list.BinaryInsert(value, Comparer(Of T).Default)
End Sub
{% endhighlight %}

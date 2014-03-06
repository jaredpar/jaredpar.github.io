---
layout: post
---
Recently I was asked how can you get a list of anonymous type member names given a query of anonymous types.  The quick answer is that you can use a quick bit of reflection to get back the names.

{% highlight vbnet %}
Public Function GetAnonymousTypeMemberNames(Of T)(ByVal anonymousType As T) As List(Of String)
    Dim type = GetType(T)
    Dim list = New List(Of String)
    For Each cur In type.GetProperties(Reflection.BindingFlags.Public Or Reflection.BindingFlags.Instance)
        list.Add(cur.Name)
    Next
    Return list
End Function
{% endhighlight %}

The longer question is how can you get back a list of anonymous type member names given a query result?  As long as you know the query will be populated you can just use the first member to get your result.

{% highlight vbnet %}
Dim q = From it In "astring" Select a = it, b = it & "b"
GetAnonymousTypeMemberNames(q.First())
{% endhighlight %}

However you can't guarantee that a query will always have data in it.  Another route is to consider the contract of the From ... Select statement.  This will produce a query which implements [IEnumerable(Of T).](http://msdn2.microsoft.com/en-us/library/9eekhta0.aspx)  For a query T will be the anonymous type that is generated[1].  We can query the metadata of the returned type to get the System.Type for the anonymous type regardless of the type actually implementing [IEnumerable(Of T).](http://msdn2.microsoft.com/en-us/library/9eekhta0.aspx)

{% highlight vbnet %}
Dim q = From it In "astring" Select a = it, b = it & "b"
Dim enumerableInterface = GetType(IEnumerable(Of ))
Dim enumerableType = q.GetType().GetInterface(enumerableInterface.FullName)
Dim anonymousTypeType = enumerableType.GetGenericArguments(0)
{% endhighlight %}

[1] This is assuming that you didn't write a query which returns a field directly and avoids creating the anonymous type.


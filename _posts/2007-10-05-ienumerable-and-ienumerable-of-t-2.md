---
layout: post
---
Quick follow up to my earlier [post]({% post_url 2007-10-04-ienumerable-and-ienumerable-of-t %}).  Fixing this issue in C# is even easier because of the existence of iterators.

    
{% highlight csharp %}
public static IEnumerable<object> Shim(System.Collections.IEnumerable enumerable)
{
    foreach (var cur in enumerable)
    {
        yield return cur;
    }
}
{% endhighlight %}


    


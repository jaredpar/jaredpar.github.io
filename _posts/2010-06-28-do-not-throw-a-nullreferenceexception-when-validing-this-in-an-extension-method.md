---
layout: post
---
One pattern I've started running into is developers explicitly throwing a NullReferenceException when validating the 'this' parameter of an extension method.

{% highlight csharp %}
public static void ForEach<T>(this IEnumerable<T> enumerable, Action<T> action)
{
    if (null == enumerable)
    {
        throw new NullReferenceException();
    }
    // rest omitted 
}
{% endhighlight %}

The desired behavior here is to make extension methods look even more like instance methods by adding similar exception semantics. So now a call to col.ForEach(..) throws a NullReferenceException if col is null just like it would if ForEach were a real method.  

However this is incorrect and should be avoided.

  1. A null reference has not occurred in this example. Having an exception targeted to a very specific event being raised when that event did not occur is simply incorrect.
  2. NullReferenceException is a runtime exception and should only be raised by the runtime. In several cases the runtime attaches special semantics to an exception it throws that changes the way it is handled ([StackOverflowExcepion for example)](%{ post_url 2008-10-22-when-can-you-catch-a-stackoverflowexception %}). Throwing runtime exceptions in user code means certain catch handlers can now potentially execute it at least 2 ways. This only serves to confuse developers?? [^1]
  3. Extension methods can be, and often are, still called just like a plain old static method and must play by those rules. The .Net framework guidelines are [very clear](http://msdn.microsoft.com/en-us/library/ms229025\(VS.80\).aspx) on how this case should be handled.
  4. Extension methods can validly be called on a null 'this' value and it doesn't represent an intrinsic error as it does for a normal instance method [^2]

For me #1 and #3 are the most compelling points. Violating either of these goes against established practices and semantic and leads to incorrect behavior in programs.

The correct pattern here is that for a normal static method: use an ArgumentNullException.

{% highlight csharp %}
public static void ForEach<T>(this IEnumerable<T> enumerable, Action<T> action)
{
    if (null == enumerable)
    {
        throw new ArgumentNullException();
    }
    // rest ommitted 
}
{% endhighlight %}

[^1]: I very much wish explicitly throwing runtime exceptions produced unverifiable code

[^2]: Whether or not this is a good idea is a different question


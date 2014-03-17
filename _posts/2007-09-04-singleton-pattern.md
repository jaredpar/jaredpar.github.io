---
layout: post
---
Quite awhile back I posted about how to create a re-usable singleton pattern in .Net.  Link is [here]({% post_url 2004-11-24-singleton-pattern %}).  A bit of time has passed and I've altered the pattern a bit.  The reasons for the change are some new type inference patterns and FxCop cleanliness.  

The first pattern I introduced had a couple of FxCop violations.  Namely Microsoft.Design CA1000 - Do not declare static members on generic types.  The logic here being that static methods don't have any type inference benefits as you must explicitly add the type into the name of the type you were using (in this case Singleton).

Secondly because T was at a class level rather than a method level I couldn't have granualar methods which had differing set of constraints.  The result was a pattern that was not always easy to write out.

The new pattern takes care of both of these problems.  It has two methods.  One of which can be satisfied with a trivial lambda expression.  The other can easily be used for classes that satisfy the generic constraint new() with no additional lambda.

{% highlight csharp %}
class c1
{
    public static c1 Instance1 
    {
        get { return Singleton.GetInstance(() => new c1());}
    }

    public static c1 Instance2
    {
        get { return Singleton.GetInstance<c1>(); }
    }

    public c1()
    {

    }
    
}
{% endhighlight %}

Below is the new singleton pattern.

{% highlight csharp %}
public delegate T Operation<T>();
/// <summary>
/// Used for classes that are single instances per appdomain
/// </summary>
public static class Singleton
{
    private static class Storage<T>
    {
        internal static T s_instance;
    }

    [SuppressMessage("Microsoft.Reliability", "CA2002")]
    public static T GetInstance<T>(Operation<T> op)
    {
        if (Storage<T>.s_instance == null)
        {
            lock (typeof(Storage<T>))
            {
                if (Storage<T>.s_instance == null)
                {
                    T temp = op();
                    System.Threading.Thread.MemoryBarrier();
                    Storage<T>.s_instance = temp;
                }
            }
        }
        return Storage<T>.s_instance;
    }

    public static T GetInstance<T>()
        where T : new()
    {
        return GetInstance(() => new T());
    }
}

#endregion
}
{% endhighlight %}


    

Edit: Originally forgot to add the signature for Operation<T>


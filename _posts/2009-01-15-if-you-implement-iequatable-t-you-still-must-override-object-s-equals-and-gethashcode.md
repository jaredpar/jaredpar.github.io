---
layout: post
---
CLR 2.0 introduced [IEquatable<T>](http://msdn.microsoft.com/en-us/library/ms131187.aspx) which is an interface that allows for type safe equality comparisons. Previously, the best available method for comparing equality was the virtual [Object Equals](http://msdn.microsoft.com/en-us/library/system.object.equals.aspx) method. The method is loosely typed since it takes an object as a parameter. This is easy enough to deal with on the client with a simple cast to the appropriate type.

    
{% highlight csharp %}
class Student {
    public override bool Equals(object obj) {
        var other = obj as Student;
        if (other == null) {
            return false;
        }
        // rest of comparison
    }
}
{% endhighlight %}

IEquatable<T> is a significant improvement over this pattern because it provides a strongly typed equals method. This protects both the caller and callee from passing incompatible object types. Additionally it avoids the overhead of boxing for value types.

These benefits are nice but if you implement IEquatable<T> you still must override Equals(object) and GetHashCode. Not doing so is wrong and **will** cause you pain down the road. I've explored this [topic](http://blogs.msdn.com/jaredpar/archive/2008/05/09/iequatable-of-t-and-gethashcode.aspx) briefly in the past but wanted to expand on it a bit with some concrete examples.

Before we get into the technical details of why, lets look at this from an expectation point of view. Implementing IEquatable<T> is a statement that 'this object knows what it means to be equal.'?? This in effect adds a contract to your class declaring that it knows how to be compared for equality. Your object should live up to these expectations in order to avoid confusing other programmers who aren't intimately familiar with your class. Confusing programmers is rarely a good idea.

**Issue #1: IEqualityComparer<T> requires GetHashCode()**

Strongly typed collections such as Dictionary<TKey,TValue> and HashSet<T> must be able to compare objects for equality in order to function. Starting in 2.0, the BCL provides an interface by which object equality semantics can be performed: IEqualityComparer<T>. This class is used in many other places besides collections, but inspecting the collection classes is the easiest way to get a feel for it's use.

Lets take a look at the definition of IEqualityComparer<T>

{% highlight csharp %}
public interface IEqualityComparer<T> {
    bool Equals(T x, T y);
    int GetHashCode(T obj);
}
{% endhighlight %}

The default definition is an internal class in the BCL named GenericEqualityComparer<T>. The default implementation of IEqualityComparer<T>
relies on IEquatable<T> for it's implementation.

But if it uses IEquatable<T> for it's implementation how can it possible implement GetHashCode()' Simple, it uses Object.GetHashCode(). This means an object must implement IEquatable<T> and GetHashCode() in order to function correctly in places where IEqualityComparer<T> is used.  

But wait, I don't actually implement IEqualityComparer<T> anywhere so I'm safe right' Unfortunately no. Very few people actually implement IEqualityComparer<T>. Instead they use EqualityComparere<T>.Default to access a given IEqualityComparer<T> for a given type T.

In fact, the standard pattern for methods which take an IEqualityComparer<T> is to have an overload that doesn't and pass EqualityComparer<T>.Default to the one that does.

{% highlight csharp %}
public static class Example {
    public static IEnumerable<T> Distinct<T>(this IEnumerable<T> source) {
        return Distinct(source, EqualityComparer<T>.Default);
    }
    public static IEnumerable<T> Distinct<T>(
        this IEnumerable<T> source, 
        IEqualityComparer<T> comparer) {
        // implementation
    }
}
{% endhighlight %}

If your object implements IEquatable<T> this will eventually cause it to create an instance of GenericEqualityComparer<T> and hence a reliance on GetHashCode.

**Issue #2: Non-Strongly typed collections and Frameworks don't use IEquatable<T>**

IEquatable<T> only provides equality comparisons in strongly typed scenarios.  It is not convenient to access this interface in less strongly typed scenarios. Consider for instance the original 1.0 collection classes: ArrayList, Hashtable, etc '?? These are all object based collections and have no way in which to cast to IEquatable<T>. Instead these collections must rely on the Object based methods of Equality.

Without implementing Object.Equals and Object.GetHashCode your type will not actually do any sort of comparison. This will cause lots of incorrect behavior for programmers who expect the class to understand equality.  
    
{% highlight csharp %}
class Person : IEquatable<Person> {
    public readonly string Name;
    public Person(string name) {
        Name = name;
    }
    public bool Equals(Person other) {
        if (other == null) {
            return false;
        }
        return StringComparer.Ordinal.Equals(Name, other.Name);
    }
}
static void EqualityCheck() {
    var p = new Person("Bob");
    var list = new ArrayList();
    list.Add(p);
    Console.WriteLine(list.Contains(p)); // Prints: True
    Console.WriteLine(list.Contains(new Person("Bob")));    // Prints: False
}
{% endhighlight %}

This goes against expectation. Both Person instances in this case are equal by definition of Person yet Contains fails. Implementing Object.Equals and Object.GetHashCode will remove this confusion.

The list of frameworks which still use loosely typed collections include WinForms, WPF, WebForms, etc '?? It's almost inevitable that you will end up using a loosely typed collection in your project somewhere.  

**Isssue #3: Equality and hash codes are linked in the BCL**

Rightly or wrongly, equality and hash codes are unbreakably linked in the BCL.  If an object can be compared for equality it also must be able to produce a hashcode.'? This implicit contract exists many places throughout the framework.  As previously displayed, implementing Object.Equals() after implementing IEquatable<T> is straight forward and boiler plate code. Object.GetHashCode can be a bit trickier because there are many [implicit contracts](http://blogs.msdn.com/jaredpar/archive/2008/04/28/properly-implementing-equality-in-vb.aspx) for GetHashCode. Often mutable objects cannot provide an efficient hashing mechanism. In that case just [return 1](http://blogs.msdn.com/jaredpar/archive/2008/06/03/making-equality-easier.aspx). This will satisfy all of the implicit contracts around GetHashCode() and takes little time to do. Yes, it will cause a Dictionary to effectively be a linked list. But that's a heck of a lot better than simply not working at all.


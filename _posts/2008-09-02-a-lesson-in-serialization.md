---
layout: post
---
A few days ago, I recklessly added a [Serialization] attribute to a few of my immutable collection types. I needed to pass data between AppDomain's and adding [Serialization] was the quick and dirty fix. Compiled, ran and I didn't think much about it.

Luckily I was updating some unit tests last night and I remembered this and added a couple of serialization sanity tests. Most of the tests passed first time but for my ImmutableStack class[^1] was throwing an exception. Well, it was actually my ImmutableQueue but it was failing in one of the inner ImmutableStack instances. The test code was fairly straight forward

    
{% highlight csharp %}
var stack = ImmutableStack.Create(new int[] { 1, 2, 3 });
using (var stream = new MemoryStream()) {
    var f = new BinaryFormatter();
    f.Serialize(stream,stack);
    stream.Position = 0;
    var obj = f.Deserialize(stream);
    var stack2 = (ImmutableStack<int>)obj;
    var stack3 = stack2.Reverse();
}
{% endhighlight %}

I did a bit of digging and discovered the exception was coming from the stack2.Reverse() call. Jumped through the code and didn't see much wrong. I had several existing tests around ImmutableStack.Reverse() and I couldn't see why Serialization would make any difference.

{% highlight csharp %}
public ImmutableStack<T> Reverse() {
    var r = ImmutableStack<T>.Empty;
    var current = this;
    while (current != ImmutableStack<T>.Empty) {
        r = r.Push(current.Peek());
        current = current.Pop();
    }

    return r;
}
{% endhighlight %}

Can you see what's wrong with the code?

It took me a few minutes of debugging and frustration. The bug is in the while loop conditional. Until you introduce serialization this code is just fine. ImmutableStack<T>.Empty is a static readonly declaration. The code implementation only allows for one to be created so it a singleton and equality can be done with a quick reference check.

{% highlight csharp %}
private static readonly EmptyImmutableStack s_empty = new EmptyImmutableStack();

public static ImmutableStack<T> Empty {
    get { return s_empty; }
}
{% endhighlight %}

Unfortunately serialization breaks the assumption that EmptyImmutableStack is a singleton. The EmptyImmutableStack class is a singleton by convention only.  It's a private nested class that's only instantiated once per AppDomain.  There is nothing stopping the CLR or Serialization for that matter from creating a second instance. In the case of deserialization that's exactly what happens. The serializer isn't built to recognize this pattern and instead simply creates a new instance of EmptyImmutableStack upon deserialization.

This essentially prevents you from safely using a functional style Empty pattern inside a serializable collection.

The fix is simple enough, alter the conditional to be (!current.IsEmpty).

[^1]: The version of ImmutableStack I'm using is heavily based off of [Eric Lippert's implementation](http://blogs.msdn.com/ericlippert/archive/2007/12/04/immutability-in-c-part-two-a-simple-immutable-stack.aspx).  

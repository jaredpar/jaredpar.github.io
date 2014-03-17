---
layout: post
---
This discussion is building upon a previous post on how to acquire an [anonymous type ... type]({% post_url 2007-08-01-coding-quiz-anonymous-type-types %}).

The next question is, how can you cast an arbitrary object into an anonymous type?  At a glance this doesn't seem possible as you cannot directly express the type of an anonymous type in code.  For instance the following code is not legal.

    
{% highlight vbnet %}
Dim o As Object = SomeCall() 
Dim x = Directcast(o, New With {.a = 5})
{% endhighlight %}

Even though it's not possible to directly express the type in code, we can indirectly express it via type inference.  Anonymous Types are strongly typed in the compiler and it is possible to infer these types where inference is available.

{% highlight vbnet %}
Public Function CastSpecial(Of T)(ByVal o As Object, ByVal t As T) As T 
    Return DirectCast(o, T)
End Function 
{% endhighlight %}

The above function allows us to perform a DirectCast as long as we have an instance of the type we want to cast to.  Now we can call the code and passing in the appropriate anonymous type instance.

{% highlight vbnet %}
 Dim o As Object = SomeCall()
 Dim x = CastSpecial(o, New With {.a = 5})
{% endhighlight %}

There are a couple of caveats to this approach though.

  1. The actual anonymous type and the one you are casting to must be exactly the same.  No polymorphism can be involved.
  2. The anonymous type must be created in the same assembly where you are performing the cast.  Anonymous types are specific to the assembly they are created in so performing the cast accross assemblies will cause a InvalidCastException to occur.
  3. It does needlessly create an object to perform the cast.


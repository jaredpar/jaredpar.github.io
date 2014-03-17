---
layout: post
---
For previous articles in this series please see

  * [Part 1: Introduction]({% post_url 2007-04-27-closures-in-vb-part-1 %})
  * [Part 2: Method Calls]({% post_url 2007-05-03-closures-in-vb-part-2-method-calls %})

Thus far in the series we've only lifted variables that are declared in the same block/scope. What happens if we lift variables in different scope?  The answer is that one closure class will be created for every unique scope where a lifted variable is declared and all of the variables in that scope that are lifted will be placed in that closure.  Once again, examples speak best

{% highlight vbnet %}
Sub Scope1()
    Dim x = 5
    Dim f1 = Function(ByVal z As Integer) x + z
    Console.WriteLine(f1(5))
    If x > 2 Then
        Dim y = 6
        Dim g = 7
        Dim f2 = Function(ByVal z As Integer) z + y + g
        Console.WriteLine(f2(4))
    End If
End Sub
{% endhighlight %}

The code will end up looking like so ...

{% highlight vbnet %}
Class Closure1
    Public x As Integer

    Function Lambda_f1(ByVal z As Integer)
        Return x + z
    End Function

End Class

Class Closure2
    Public y As Integer
    Public g As Integer

    Function Lambda_f2(ByVal z As Integer)
        Return y + z + g
    End Function
End Class

Sub Scope1()
    Dim c1 As New Closure1()
    c1.x = 5
    Console.WriteLine(c1.Lambda_f1(5))
    If c1.x > 2 Then
        Dim c2 As New Closure2()
        c2.y = 6
        c2.g = 7
        Console.WriteLine(c2.Lambda_f2(4))
    End If
End Sub
{% endhighlight %}

There are a couple of items to take away from this example.

  1. Only two closure classes were created even though three variables were lifted.  The number of closures only depends on the number of scopes of all of the lifted declared variables. 
  2. The closures are created at the begining of the scope they are associated and not at the begining of the method.  This will be more important in the next part of the series. 
  3. Each lambda instance is attached to the closure associated with the scope the lambda is declared in. 

The next twist is what were to happen if the lambda "f2" were to also use the variable "x".  As it's currently written there is no association between Closure1 and Closure2 therefore there is no way for it to access the lifted variable.  The answer is two fold.  Firstly to reduce clutter I pasted the closure classes as if they were separate entries.  In fact Closure2 would appear as a nested class of Closure1 in the real generated code.  

Secondly if x were used inside of "f2", the real use would be "c1.x".  That's (almost) no different than "someOtherVar.x".  Therefore the instance of c1 will be lifted into Closure2.
    
{% highlight vbnet %}
Dim f2 = Function(ByVal z As Integer) z + y + g + x
{% endhighlight %}

Woud result in the following definition of Closure2 ...

{% highlight vbnet %}
Class Closure2
    Public y As Integer
    Public g As Integer
    Public c1 As Closure1

    Function Lambda_f2(ByVal z As Integer)
        Return y + z + g + c1.x
    End Function
End Class
{% endhighlight %}

In deeply nested lambdas and scopes this type of lifting will continue recursively.

That's it for this entry, the next article will talk about looping structures and possibly variable lifetime.


---
layout: post
---
For previous articles in this series, please see

  * [Part 1: Introduction]({% post_url 2007-04-27-closures-in-vb-part-1 %})

This part of the series will focus on how method calls are handled in closures.  As stated in the previous article, the purpose of closures is to allow all operations inside a lambda or query expression that would normally be available inside the function or sub.  To do this closures often need to capture (or lift) relevant variables from the function into the generated class.

There are 2 types of methods and method calls that closures have to handle.

1. Method calls to a shared method or methods on modules. 
2. Method calls to instance members of a class 

**Scenario #1 **

Below is an example of a method call inside a lambda expression for scenario #1.

{% highlight vbnet %}
Module M1

    Function MyValue() As Integer
        Return 42
    End Function

    Sub Example1()
        Dim x = 5
        Dim f = Function() x + MyValue()
    End Sub

End Module
{% endhighlight %}

Here we are calling a module method inside a lambda.  Module Methods or Shared methods can be called from anywhere because they require no specific variable for the call.  This requires no special work from closures as the call can just be made naturally.

{% highlight vbnet %}
Class Closure
    Private x As Integer

    Function Lambda_f() As Integer
        Return x + M1.MyValue
    End Function
End Class
{% endhighlight %}

**Scenario #2**

Calling an instance method is more difficult than a shared method because it requires the referenc "Me".  If you don't type this specifically in code the VB Compiler will add it for you under the hood.  To make this work the closures code will also "lift" the variable "Me" in the same way that it lifts normal variables in a function.

Calling a instance method inside a lambda expression is little difference than calling a member method on a variable used in a lambda.  The only difference is the variable is "Me".  For example

{% highlight vbnet %}
Class C1
    Private m_myValue As Integer

    Function MyValue() As Integer
        Return m_myValue
    End Function

    Sub Example2()
        Dim x = 5
        Dim f = Function() x + MyValue()
    End Sub
End Class
{% endhighlight %}

In this case we need to access both "x" and "Me.MyValue()" from the closure.  The generated code will create space for both of these variables and the transformed code in Example2 will store both of the values.

{% highlight vbnet %}
    Class Closure
        Private x As Integer
        Private OriginalMe As C1
    
        Function Lambda_f()
            Return x + OriginalMe.MyValue()
        End Function
    End Class

    Sub Example2()
        Dim c As New Closure
        c.x = 5
        c.OriginalMe = Me
        Dim f = New Func(Of Integer)(AddressOf c.Lambda_f)
    End Sub
{% endhighlight %}

As usual, the generated code is much uglier but this essentially what will be generated.  That wraps it up for method calls.  In the next part, I will discuss the variable liftetime and scoping issues that come into play with closures.


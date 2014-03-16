---
layout: post
---
One of the overlooked or simply misunderstood features of the VB language is calling a function which has a ByRef parameter. Most languages support only a single method of passing parameters by reference [^1], that is the scenarios directly supported by the CLR. The CLR has a lot of restrictions on the type of values it supports for ByRef parameters and these restrictions get in the way of VB's goal to be a flexible language that strives to get out of the way of the user. Hence the compiler goes to great lengths to be flexible and support multiple avenues of ByRef passing, much beyond what the CLR natively allows.

This article will explore these different mechanisms. In order to reduce the code samples, I will be using the following 2 methods to explain the different mechanisms of ByRef Passing

    
{% highlight vbnet %}
Sub FunctionWithInt(ByRef p1 As Integer)
    p1 = 42
End Sub


Sub FunctionWithObject(ByRef p1 As Object, ByVal p2 As Object)
    p1 = p2
End Sub
{% endhighlight %}

**CLR ByRef**

The first is to simply use the CLR concept of passing by reference as defined by section 12.4.1.5.2 and 12.1.6.1 of the CLI specification. Any variable which meets any of the following criteria, does not require a type conversion, and is passed to a ByRef parameter will be passed directly in the CLR.

  * Argument of the current method 
  * Local variable 
  * Member Field of an object 
  * Static Field 
  * Array Element 

No special code is needed or generated for this scenario.

**Copy Back ByRef**

While the CLR method of passing ByRef is very flexible, it disallows a number of useful scenarios. The most prominent of which is properties. Properties do not meet the CLR requirements for ByRef because under the hood they are simply a pair of function calls. The result of a function call cannot be directly passed by reference.

Without any language intervention this can be very confusing to users.  Properties are very often simple get/set wrappers around fields and have almost the exact same usage scenarios. To the point that most users don't see a functional difference between the two. Auto-implemented properties blur this line even further. Not being able to pass them ByRef creates an unacceptable inconsistency in their usage.

VB removes this inconsistency and allows properties to be passed by reference.  This is implemented under the hood by means of a temporary variable.  Temporaries are just local variables and hence can be passed by reference.  The property value is assigned to a temporary which is then passed by reference and then after wards is copied back into the original property.

For example, take the following code sample

{% highlight vbnet %}
Class C1
    Public Property P1 As Integer
    Public P2 As Integer
End Class
Sub CopyBackByRef()
    Dim v1 = New C1
    FunctionWithInt(v1.P1)
End Sub
{% endhighlight %}

This will result in essentially the following code being generated

{% highlight vbnet %}
Sub CopyBackByRef_Explained()
    Dim v1 = New C1
    Dim vbTemp = v1.P1
    FunctionWithInt(vbTemp)
    v1.P1 = vbTemp
End Sub
{% endhighlight %}

This type of ByRef passing is used in the following 2 scenarios

  1. The value is a Property containing both a getter and setter.
  2. Passing the value to the function requires a conversion. 

The first can be done with even the strictest Option settings. However #2 can only be used with Option Strict Off because it requires an implicit narrowing conversion.

**Don't Copy Back ByRef**

So far we've only looked at scenarios where the user wants to actually see the value returned from the ByRef parameter. There are many scenarios where the language can infer the user does not care about the return value of the function. For example, what if I just want to pass a constant value?  
    
{% highlight vbnet %}
        Sub DontCopyBackByRef()
            FunctionWithInt(42)
        End Sub
{% endhighlight %}


This code is legal in VB and represents another method of passing by ref.  This is very similar to the copy back method of passing by reference. The only difference is that it never copies the value back. It essentially generates the following code

    
{% highlight vbnet %}
Sub DontCopyBackByRef_Explained()
    Dim vbTemp = 42
    FunctionWithInt(vbTemp)
End Sub
{% endhighlight %}

This type of ByRef is used in any scenario where the value being passed cannot
be assigned to. For example

  * The result of function calls 
  * Read Only Properties 
  * Constant Values 

**Maybe Copy Back ByRef**

Up until now we've examined cases where the compiler can examine both the
value being passed and the parameter it is being passed to and make a
determination about what direction the data needs to move in. What about late
binding?

    
{% highlight vbnet %}
Sub MaybeCopyBackByRef()
    Dim v1 As Object = Me
    Dim v2 = 13
    v1.FunctionWithInt(v2)
End Sub
{% endhighlight %}

Here v1 is typed to object and hence FunctionWithInt is being accessed via late binding. In this case the compiler doesn't know the actual method being invoked runtime. Hence it cannot know up front if the parameters are ByRef or ByVal and cannot make an up front decision on the variable passing mechanism.

In order to make late binding invokes flow as smoothly as normal method invokes, the compiler will generate code to conditionally update the original value based on the runtime information about the parameter. The late binder communicates this information via an array of Boolean values, one for each parameter passed to the function. The compiler will initialize this array with true for any values it knows are updatable and false for values that are not. The late binder will then examine every parameter to the function and set the corresponding index in the array to false if the method parameter is ByVal. If it is ByRef the returned value from the function will be copied back into the original parameter array.

The resulting code looks a bit like this. You can ignore all of the Nothing values as they are not important for this discussion.

    
{% highlight vbnet %}
Sub MaybeCopyBackByRef_Explained()
    Dim v1 As Object = Me
    Dim v2 = 13
    Dim parameters = New Object() {v2}
    Dim isByRef = New Boolean() {True}
    NewLateBinding.LateCall(v1, Nothing, "FunctionWithInt", parameters, Nothing, Nothing, isByRef, True)
    If (isByRef(0)) Then
        v2 = CInt(parameters(0))
    End If
End Sub
{% endhighlight %}

[^1]: Starting with version 4.0, C# now supports two versions of reference passing. In addition to the one available since 1.0 the ref modifier is now optional when making an interop call to a COM object: <http://mutelight.org/articles/new-features-in-c-sharp-4.html>


---
layout: post
---
One of the gotchas for Extension Methods is that it's legal to call them on Null References.  This isn't really surprising when you think about the feature.  Boiled down to a fundamental level, extension methods are just syntactic sugar for calling a static method and automatically passing the first parameter [^1].  However it can catch the unwary off guard.

The two items that are a little bit different between calling an Instance vs Extension method on a null reference is

  1. The exception (if thrown) will be at the method site instead of the call site.  Not really an issue because you can just jump down the stack frame. 
  2. There may not be an exception thrown.  As long as you don't actually use the extension method target, the code will not necessary throw[^2].  For instance consider the following code
    
{% highlight vbnet %}
<Extension()> _
Public Function IsNothing(ByVal o As Object) As Boolean
    Return o Is Nothing
End Function


Sub Test()
    Dim x As String = Nothing
    Dim b = x.IsNothing()   ' b = True
End Sub
{% endhighlight %}

This is legal and will not throw.  However I don't recomend that you write it.

[^1]: Then again you could also claim that instance methods are just syntactic sugar for calling static methods without having to pass this/Me as the first parameter.

[^2]: In some ways this is similar to C++.  C++ doesn't do NULL reference checking automatically (it waits for you to access data on a NULL reference and then crashes if you're lucky).  If you call a method on a NULL pointer but don't actually access any member variables, it will likely run fine.


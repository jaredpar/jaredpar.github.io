---
layout: post
---
For previous articles in this series please see

  * [Part 1: Introduction](http://blogs.msdn.com/jaredpar/archive/2007/04/27/closures-in-vb-part-1.aspx)
  * [Part 2: Method Calls](http://blogs.msdn.com/jaredpar/archive/2007/05/03/closures-in-vb-part-2-method-calls.aspx)
  * [Part 3: Scope](http://blogs.msdn.com/jaredpar/archive/2007/05/25/closures-in-vb-part-3-scope.aspx)

Sorry for the long delay between posts here.  We're getting Orcas out the door and getting this series completed takes a back door to shipping.

Originally I wanted to talk about looping structures next.  However when I started writing that post I realized that I had to talk about lifetime before the looping structures would make sense.  

Prior to Orcas the lifetime of a variable in VB was the entire function.  This presented several problems from a closures perspective.  Imagine you had a looping structure and the value was used in a lambda expression.  

{% highlight vbnet %}
Sub LifetimeExample()
    Dim list As New List(Of Func(Of Integer))
    For i = 0 To 5

        Dim x = i * 2
        If True Then
            list.Add(Function() x)
        End If
    Next

    For Each f In list
        Console.Write(f() & " ")
    Next
End Sub
{% endhighlight %}

In this example if we left the lifetime rules unchanged, there would be a single variable "x" for the entire function.  That means that we would end up printing out

    10 10 10 10 10

This is somewhat unexpected and essentially means that VB could not support complex Lambda scenarios.  To fix this we altered the lifetime of variables to be tied to the scope they were contained in.  The end effect is that each iteration of the loop has a separate "x" since each iteration enters and leaves the scope of the "if" statement.  As a result it will print out

    0 2 4 6 8 10

We did make one backcompat adjustment for this change.  The lifetime of variables in VB was visible if you tried to use an uninitialized variable in a loop/goto.  For instance the following code will also print out 0 2 4 6 8 10 because it takes advantage of the fact that the variable "x" has a lifetime longer than the loop.

{% highlight vbnet %}
Sub VisibleLifetime()
    For i = 0 To 5
        Dim x As Integer
        Console.WriteLine(x)
        x += 2
    Next
End Sub
{% endhighlight %}

To make sure that we didn't break any existing code we had one little errata for the change.  When a variable's scope is re-entered, and hence recreated, and it is not initialized to a value it will get the last value of the variable.


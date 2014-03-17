---
layout: post
---
For previous articles in the series please see

  * [Part 1: Introduction]({% post_url 2007-04-27-closures-in-vb-part-1 %})
  * [Part 2: Method Calls]({% post_url 2007-05-03-closures-in-vb-part-2-method-calls %})
  * [Part 3: Scope]({% post_url 2007-05-25-closures-in-vb-part-3-scope %})
  * [Part 4: Variable Lifetime]({% post_url 2007-06-15-closures-in-vb-part-4-variable-lifetime %})

Once again sorry for the long delay between posts.

Looping structures can cause unintended consequences when used with Lambda expressions.  The problem occurs because lambda expressions do not execute when they are constructed but rather when they are invoked.  For example take the following code.

{% highlight vbnet %}
Sub LoopExample1()
    Dim list As New List(Of Func(Of Integer))
    For i = 0 To 3
        list.Add(Function() i)
    Next

    For Each cur In list
        Console.Write("{0} ", cur())
    Next
End Sub
{% endhighlight %}

Many users are surprised to find out the above will print "4 4 4 4 ".  The reason goes back to my previous 2 posts on variable lifetime and scope.  All "For" and "For Each" blocks in Vb have 2 scopes.

  1. Scope where iteration variables are defined 
  2. Body of the for loop

The first scope is entered only once no matter how many times the loop is executed.  The second is entered once per iteration of the loop.  Any iteration variables that are defined in a For/For Each loop are created in the first scope (in this case "i" and "cur").  Hence there is only one of those variables for every loop iteration and the lambda function lifts the single variable "i".

This has thrown off many users because the behavior works most of the time.  For instance if I switched the code to run "Console.Write" inside the first loop, it would print out "0 1 2 3 " as expected.  

To mitigate against this problem the above code will actually produce a warning in VB.

> warning BC42324: Using the iteration variable in a lambda expression may have unexpected results.  Instead, create a local variable within the loop and assign it the value of the iteration variable.

There are two ways to fix this problem depending on the behavior you want.  If you see this warning and don't know if it affects you, the safest change is to do the following.

{% highlight vbnet %}
Sub LoopExample2()
    Dim list As New List(Of Func(Of Integer))
    For iTemp = 0 To 3
        Dim i = iTemp
        list.Add(Function() i)
    Next

    For Each cur In list
        Console.Write("{0} ", cur())
    Next
End Sub
{% endhighlight %}

This will cause "i" to be created in the second scope.  Hence there will be a different value for every loop iteration and the code will print out "0 1 2 3" as expected.

If you do want the code to print out "4 4 4 4 " then add "Dim i = 0" before the start of the loop.


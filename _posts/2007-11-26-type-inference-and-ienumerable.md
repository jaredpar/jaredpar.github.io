---
layout: post
---
This is somewhat of a follow up on a previous [post]({% post_url 2007-10-04-ienumerable-and-ienumerable-of-t %}) I did on the difference between [IEnumerable(Of T)](http://msdn2.microsoft.com/en-us/library/9eekhta0.aspx) and the [IEnumerable](http://msdn2.microsoft.com/en-us/library/9eekhta0.aspx) interfaces.

I've seen several people type in the following code and wonder if there was a fundamental bug in the type inference code.

{% highlight vbnet %}
Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
    For Each cur In Controls
        cur.Text = "A Value"
    Next
End Sub
{% endhighlight %}

This code will produce an error stating that "Text" is not a member of object.  Users expected type inference to type the variable "cur" as Control.  Unfortunately this is "By Design".

Much of the original .Net Framework was written before the CLR implemented support for generics.  As a result all of the collection classes were loosely typed to Object by implementing [IEnumerable](http://msdn2.microsoft.com/en-us/library/9eekhta0.aspx).  So in this case type inference will correctly type this as Object.

There are 2 ways to fix this problem.

1. Explicitly type the For Each variable to be the actual type of objects in the collection
2. Use a Shim to change the type of the [collection]({% post_url 2007-10-04-ienumerable-and-ienumerable-of-t %})


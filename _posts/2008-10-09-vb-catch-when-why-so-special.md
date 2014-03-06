---
layout: post
---
The VB Catch syntax has a particular feature not present in C#: When.  It allows users to filter expressions based on something other than their type.  Any arbitrary code can enter a When block to decide whether or not to handle an Exception

{% highlight vbnet %}
Sub Sub1()
    Try
        DoSomeAction()
    Catch ex As Exception When Filter(ex)
        Stop
    End Try
End Sub
{% endhighlight %}
    

Newsgroups often ask, "Why's this so special? I could effectively get the same behavior out of C# by doing the following."

{% highlight csharp %}
static void Sub1()
{
    try
    {
        DoSomeAction();
    }
    catch (Exception ex)
    {
        if (Filter(ex))
        {
            throw;
        }
        HandleException();
    }
}
{% endhighlight %}

This is true to an extent.  In both cases the code is handling an exception and making a decision, via calling Filter, as to whether or not to handle the exception.  The subtle difference is when the Filter method is called.  

In VB the When statement is actually implemented as an IL exception filter.  When an exception is thrown, exception filters are processed before the stack is unwound.  This means that if the Filter method created an error report that included the current stack trace, it would show the frame in which the exception occurred.

For example, in the code above if DoSomeAction() threw and the stack was examined in the Filter expression, the following stack would show up.

![image](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/VBCatch.WhenWhysospecial_1299E/image_thumb.png)

Notice how the DoSomeAction method is clearly visible?  This is incredibly powerful for features like error reporting and investigation.  It also allows you to set powerful breakpoints where the exact state of the error can be examined and not just the post mortem.

Alternatively, code executed in the C# block will occur after the stack is unwound.  This gets rid of the culprit.  As long as your not in optimized code you can usually use the stack trace properties to get the source of the exception but you won't be able to examine the live state of the error.

![image](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/VBCatch.WhenWhysospecial_1299E/image_thumb_1.png)


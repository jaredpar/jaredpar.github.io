---
layout: post
---
One of the seldom used, and often unknown, features of VB extension methods is that the argument of the extension method (the first parameter) can be passed by reference. This gives extension methods the power to change the reference that was used to invoke the value!

Obviously this can produce unexpected but often amusing behavior. The following sample prints 'False'.
    
``` vb
<Extension()> _
Public Sub EnsureNotNull(ByRef str As String)
    If str Is Nothing Then
        str = String.Empty
    End If
End Sub

Sub Example(ByVal p1 As String)
    p1.EnsureNotNull()
    Console.WriteLine("{0}", p1 Is Nothing)
End Sub

Sub Main()
    Example(Nothing)
End Sub
```

I think people will look at this example and either cringe, call it terrible code or get excited. Personally I'm somewhere between cringing and getting excited (in fact I'm doing both). But before people think I've gone off the deep end I don't plan on checking this in any time soon (and yes I think it's a bad idea).

Why' The feature is fun to play with and can create some interesting samples but it can also just as easily lead to very bad and unanticipated behavior.  For instance what if instead of making sure something wasn't Nothing, the code made the argument Nothing?

``` vb
<Extension()> _
Sub EvilMethod(ByRef p1 As Object)
    p1 = Nothing
End Sub

Sub Example2()
    Dim s As New Student()
    s.PrintClass()
    s.EvilMethod()
    s.PrintName()   ' Causes a NullReferenceException
End Sub
```

The code runs and throws an exception. A developer attaches a debugger, looks at the exception but immediately notes there are 2 other method calls just above. How could they succeed but the last throw a NullReferenceException' Certainly this may be a fun joke but in production code a fellow developer would not be amused.

More importantly though the behavior when passing an extension method target by reference is flat out unexpected. Who expects what appears to an instance method call to be able to modify 'Me/this'' Probably not too many people.  Coding is difficult enough without creating patterns that will blow away anyone who owns your code down the line. Code should do it's best to be clear and produce predictable results.

Still, an interesting feature to toy with.


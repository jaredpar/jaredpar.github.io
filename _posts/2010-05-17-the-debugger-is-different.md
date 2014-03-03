---
layout: post
---
The goal of the debugger is to provide rich inspection capabilities for a process. The main method of inspection is through the evaluation of textual expressions which is handled by a language specific component known as the [expression evaluator](http://msdn.microsoft.com/en-us/library/bb144988.aspx).  This component is the data provider for a good portion of the debugger windows (watch, locals, autos, etc ')

The expression evaluators go to great lengths to ensure that expression in the debugger evaluate exactly as it would if the expression was typed at the current place in the file where the debugger was stopped. To do otherwise only leads to user confusion. Often making it harder to track down the issue you're currently debugging and resulting in a loss in faith in the quality of the debugger and language.  

Occasionally, or not so occasionally, the goals of providing high fidelity in evaluation and rich inspection conflict. When this occurs we have to weight the tradeoffs of confusing users by changing the semantics of the language vs.  the resulting increased capabilities in the debugger.

One example is accessibility. Languages have strong notions of accessibility which is enforced by the compiler and CLR. In order to provide rich inspection though the debugger must be able to access all available data including items which are not accessible by the language. To do otherwise might arbitrarily hide that one piece of data a developer needs to solve the problem at hand.'? Hence accessibility is one case where the expression evaluators bend language rules and allow expressions to access data without accessibility checks.

One the surface this doesn't seem like a big change. It's an additive change allowing users to see more fields, properties and methods. In the majority case it's as simple as that and leads to little confusion.

However even seemingly simple changes like removing accessibility checks can lead to very surprising behavior for our users. Recently our QA team filed a bug that illustrates this point.

{% highlight vbnet %}
    Module Module1
        Class Base
            Private Field1 As Integer = 55
        End Class
    
        Class Derived
            Inherits Base
            Sub Method1()
                Field1 = 72
                Stop
            End Sub
        End Class
    
        Sub Main()
            Dim x As New Derived
            x.Method1()
        End Sub

    End Module

    Module Module2
        Public Field1 As Integer
    End Module
{% endhighlight %}

QA noted that if they ran this code and typed Field1 in the watch window that the value showed 55 instead of 72. This was noted as a bug because Field1 was set to 72 on the line before.

Interestingly enough though is that this behavior, while very confusing, is actually 'By Design'.

The reason why is that when evaluating expressions in the debugger nothing is private. Knowing this reconsider what it means to evaluate Field1 inside of Method1 with both instances being Public. The correct binding is Base::Field1 since the VB language prefers instance fields over Module fields if they are both accessible. The expression evaluator correctly evaluates this as 55.

However when the code was compiled accessibility checks were in place. This mean that Base::Field1 was not considered since it was private and inaccessible. The compiler instead correctly bound to Module2::Field1 and this is the field which is used when the code is running. Developers can verify this by evaluating Module2.Field1 in any of the debugger windows.  

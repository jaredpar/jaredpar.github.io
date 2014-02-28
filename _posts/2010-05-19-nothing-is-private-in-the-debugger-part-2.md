---
layout: post
---
In a [previous post](http://blogs.msdn.com/jaredpar/archive/2010/05/17/the-
debugger-is-different.aspx) I discussed how accessibility is ignored when
evaluating expressions in the debugger and the unexpected scenarios that it
creates.?? One case I neglected to mention in that article is how this behavior
works with the VB late binding engine.

The expression evaluator only relaxes accessibility rules when binding an
expression.?? This is possible because the expression evaluator effectively
hosts the compiler and can override items like accessibility checks.

In the case of late binding the compiler only participates in building an
expression that will call into the VB runtime late binding engine.?? The
accessibility determination for the target of late bound call occurs in the VB
runtime and is not (currently) overidable by the expression evaluator.

Late bound access combined with static access can lead to additional confusing
behavior.?? For example.

    
    
    Class C1


        Private Field1 As Integer


        Public Property Property1 As Integer


    End Class


    


    Module Module1


    


        Sub Main()


            Dim v1 As New C1


            Dim v2 As Object = v1


            Stop


        End Sub


    


    End Module


    


    

When the following code is run, all members are accessible from the v1 local.
It is statically typed to C1 and hence the expression evaluator can ignore
accessibility and access the values.

![image](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/Nothingisp
rivateinthedebuggerpart2_10EBA/image_thumb.png)

The local v2 references the same object instance so it???s reasonable to assume
it can access the same values.?? However because it???s statically typed as
object, calls like v1.Field1 actually turn into late bound calls and hence are
subject to the rules of the late binder.



![image](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/Nothingisp
rivateinthedebuggerpart2_10EBA/image_thumb_1.png)

Evaluation of Field1 fails here because the late binder does not allow access
to private fields.?? Property1 evaluates just fine though because it???s public.

We are considering changing this behavior in a future release.?? As usual no
promises.


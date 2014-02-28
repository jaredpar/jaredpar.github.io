---
layout: post
---
For previous articles in this series please see ...

  * [Part 1: Introduction](http://blogs.msdn.com/jaredpar/archive/2007/04/27/closures-in-vb-part-1.aspx)
  * [Part 2: Method Calls](http://blogs.msdn.com/jaredpar/archive/2007/05/03/closures-in-vb-part-2-method-calls.aspx)
  * [Part 3: Scope](http://blogs.msdn.com/jaredpar/archive/2007/05/25/closures-in-vb-part-3-scope.aspx)
  * [Part 4: Variable Lifetime](http://blogs.msdn.com/jaredpar/archive/2007/06/15/closures-in-vb-part-4-variable-lifetime.aspx)
  * [Part 5: Looping](http://blogs.msdn.com/jaredpar/archive/2007/07/26/closures-in-vb-part-5-looping.aspx)

As powerful as closures are in the language they do have a few limitations.
We worked hard in Orcas to put as few limitations in Orcas as possible.  Below
are the current limitations and some insight into why they exist this way.

1\. Cannot use "ByRef" parameters in a closure

Example:

    
    
        Sub LiftAByRef(ByRef x As Integer)


            Dim f = Function() x


        End Sub

Message: error BC36639: 'ByRef' parameter 'x' cannot be used in a lambda
expression.

The problem here is the expectation surrounding x.  Any change in the value of
"x" inside the method "LiftAByRef" should be reflected in the calling
function.   Normally for any lifted parameter we add a new field inside the
closure and all read/writes are redirected into that value.  For "ByRef"
parameters we would additionally have to ensure that all writes are make to
the parameter.  Even in the presence of an exception.  Not a trivial task.

2\. Cannot use "Me" in a closure created inside a structure.

Example:

    
    
    Structure S1


        Public F1 As Integer


    


        Public Sub M1()


            Dim f = Function() F1


        End Sub


    End Structure


    

Message: error BC36638: Instance members and 'Me' cannot be used within a
lambda expression in structures

Closures capture values by reference.  It's not possible to capture the "Me"
of a structure by reference in VB.  The only other option is to capture them
by value.  If we did that then all changes to members of a structure inside a
lambda would not affect the structure in which they were created; merely the
value copy.  This is very different behavior from every other place that
closures are used.  To avoid confusing behavior this is not a legal operation.

3\. Cannot use a Restricted Type in a closure

Example:

    
    
        Sub LiftRestrictedType()


            Dim x As ArgIterator = Nothing


            Dim f = Function() x.GetNextArgType().GetModuleHandle()


        End Sub


    

Message: error BC36640: Instance of restricted type 'System.ArgIterator'
cannot be used in a lambda expression.

This hopefully will not affect many users.  There are several types in the CLR
that are considered _restricted_ because they have special semantics.
Typically they are special cased by the CLR and as such we can't use them in a
closure.  Several of these cannot be used in VB at all.  They are ...

  * System.TypedReference 
  * System.ArgIterator 
  * System.RuntimeArgumentHandle

4\. Cannot Goto into scope that contains a closure

Example:

    
    
        Sub BadGoto()


            Dim x = 0


    


            GoTo Label1


            If x > 5 Then


    Label1:


                Dim y = 5


                Dim f = Function() y


            End If


        End Sub

Message: error BC36597: 'GoTo Label1' is not valid because 'Label1' is inside
a scope that defines a variable that is used in a lambda or query expression.

If you look back at [Part 3](http://blogs.msdn.com/jaredpar/archive/2007/05/25
/closures-in-vb-part-3-scope.aspx) of this series you will see that a lot of
work goes into initializing closures inside of a scope.  Unfortunately
allowing a user to jump into a block that contains a closure makes respecting
these rules very difficult.  In a even trivial example in makes the resulting
code mostly unreadable.  We decided to disable this in Orcas and reconsider it
in a future release.

It is perfectly legal however to jump into any scope that is currently visible
regardless of whether or not in contains a closure.  Because jumping into a
visible scope does not affect the creation of a variable lifetime (just the
ending), it does not add any complications to the code.

5\. Cannot mix "On Error Goto" and Closures

Message: error BC36595: Method cannot contain both an 'On Error GoTo'
statement and a lambda or query expression.

Because of restriction #4 we must disable this scenario as well since it's
very easy to hit this scenario with "On Error Goto".


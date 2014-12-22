---
layout: post
---
One of the features I implemented for VB 9.0 is lexical closure support.  This a great addition to the VB language and I wanted to do a series of blog posts to describe this feature and how it will impact your code.  

Lexical Closures (more often referred to as simply Closures) are the underpinnings for several new features in Visual Basic 9.0.  The are part of the guts of Lambda and Query expressions.  This will be a several part series on Closures in VB 9.0; how they work, their limitations, pitfalls surrounding their use.

To start off, let's get a basic summary of what a Closure is.  [Wikipedia](http://en.wikipedia.org/wiki/Closure_%28computer_science%29) defines it as "... a  is a semantic concept referring to a function paired with an environment ...".  I prefer to describe it as follows.  A closure is a feature which allows users to seemlessly access an environment (locals, parameters and methods) from more than one function.  Even better are samples
:)

``` vbnet
Class C1
    Sub Test()
        Dim x = 5
        Dim f = Function(ByVal y As Integer) x + y
        Dim result = f(42)
    End Sub

End Class
```

In this code we have a lambda expression which takes in a single parameter and adds it with a local variable.  Lambda expressions are implemented as functions in VB (and C#).  So now we have two functions, "Test" and "f", which are accessing a single local variable.  This is where closures come into play.  Closures are responsible for making the single variable "x" available to both functions in a process that is referred to as "lifting the variable".  

To do this the compiler will take essentially 4 actions.

1. Create a class which will contain "x" in order to share it among both functions.  Call it "Closure" for now 
2. It will create a new function for the lambda expression in the class "Closure".  Call it "f" for now 
3. Create a new instance of the class "Closure" inside the sub "Test" 
4. Rewrite all access of "x" into the member "x" of "Closure".
    
``` vbnet
Class Closure
    Public x As Integer

    Function f(ByVal y As Integer) As Integer
        Return x + y
    End Function
End Class

Class C1
    Sub Test()
        Dim c As New Closure()
        c.x = 5
        Dim f As Func(Of Integer, Integer) = AddressOf c.f
        Dim result = f(42)
    End Sub

End Class
```

Now "x" is shared amongst both functions and the user didn't have to know anything about the code we generated.  You can see from this simplified example just how much code Closures and all of the other new VB 9.0 features are saving you here (Type Inference, Lambda Expressions).

Note this is only a simulation of what is generated when you use a closure, the actual generated code is much uglier and involves lots of unbindable names "$Lambda_1", etc ...

In the next part of this article I'll dive into some more uses of closures (multiple variables, method access,  terminology, etc...).


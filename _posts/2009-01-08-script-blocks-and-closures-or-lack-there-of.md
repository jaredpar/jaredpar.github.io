---
layout: post
---
Script blocks are a concise way of representing an expression or statement
group in Powershell.?? It???s the C#/F#/VB lambda equivalent for PowerShell.

One difference between C#/F#/VB lambda expressions and a scriptblock is the
lack of lexical closures (otherwise known as variable capturing).?? This
feature allows for a variable defined in an outer scope to be captured by the
lambda in such a way that the value is maintained with the lambda expression.
The details on how the variable is captured can vary from language to language
but the basics are the same.

    
    
    static void ClosureExample() {


        var name = "first";


        Func<string> captureName = () => name;


        name = "second";


        Console.WriteLine(captureName());   // prints: second


    }

Due to the flexible nature of powershell it is possible for a scriptblock to
appear to have captured a variable when in fact it???s just a quirk of variable
name resolution.?? An important item to remember when considering how a
scriptblock will execute is knowing that a script block is evaluated at the
point of execution, not the point of definition.

    
    
    PS) function example1() { $b = 42; { $b } }


    PS) $b = 42


    PS) $sb = example1


    PS) & $sb


    42

The above sample works because when $sb is evaluated there is a variable $b in
scope and hence the expression binds to that value.?? Not the original one in
???example1???.

This is a somewhat contrived example.?? But the problem can easily occur when
scripts 1) contain the same variable name in multiple scopes/contexts, 2) uses
one of those variables within a script block.?? I???ve run into this problem
myself several times.

Here is a more complex sample that demonstrates the timing of the name
resolution.

    
    
    PS) function example2() { param ($p1) $v1 = "avalue"; & $p1 }


    PS) example2 {$doesnotexist}


    PS) example2 {$v1}


    avalue

This behavior though can also be used as a feature.?? Part of the implicit
contract of a scriptblock can be the existance of certain named variables in
the scope where the script block is executed.?? Probably not the best code
maintainability practice, but I think we can generate a few good samples in a
future post.


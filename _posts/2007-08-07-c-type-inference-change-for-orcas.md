---
layout: post
---
While playing around with a batch of Orcas code recently I found a welcome change to the C# type inference rules for Orcas.  The return type of a generic delegate can now be inferred from the actual return values.  Here is some sample code demonstrating the problem.  

``` csharp
class Program
{
    public delegate T Operation<T>();

    public static void M<T>(Operation<T> del)
    {

    }

    static void Main(string[] args)
    {
        M(delegate { return 42; });
}
}
```
    
In Whidbey the above code will fail with a compiler error.

    error CS0411: The type arguments for method 'ConsoleApplication34.Program.M<T>(ConsoleApplication34.Program.Operation<T>)' cannot be inferred from the usage. Try specifying the type arguments explicitly.

This is really frustrating in Whidbey because the you have to modify the call to include the actual type specifier.
    
``` csharp
M<int>(delegate { return 42; });
```
    
However this code now works without modification in Orcas.  This is a welcome and extremely useful change.

And yes, the same inference is possible with VB in Orcas.  In Whidbey this was not an issue because VB did not support lambda expressions.

``` vbnet
Module Module1

    Public Delegate Function Operation(Of T)() As T

    Public Sub M(Of T)(ByVal del As Operation(Of T))

    End Sub

    Sub Main()
        M(Function() 1)
    End Sub

End Module
```


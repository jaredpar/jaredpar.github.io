---
layout: post
---
[Last time]({% post_url 2008-01-04-tuples-part-2-basic-structure %}) we were left with a constructor that required us to explicitly specify generic parameters.  This is not always easy or possible.  We'll now alter the script to generate a constructor which utilizes type inference to create a Tuple.  In addition, all tuples will use the same overloaded method making the creation uniform.

The best way to use type inference to create a generic argument is through static methods.  In C# and VB it's legal to define a non-generic class with the same name as a generic class.  I tend to create a non-generic class with a static Create method that takes advantage of type inference.  For tuples the method will look like the following.

    
``` csharp
public partial class Tuple
{
    public static Tuple<TA> Create<TA>(TA a)
    { 
        return new Tuple<TA>(a); 
    }
}
```

This allows us to write the following code.

``` csharp
var tuple = Tuple.Create("foo");
```

Partial classes are used because we will be generating one per Tuple class that we create.  It's just easier to script it this way.

The method is very straight forward.  We need one new additional string for the arguments to the constructor.  It's created along the same line as the previous strings.  

    function script:Gen-InferenceConstructor  
    {  
        param ( [int] $count = $(throw "Need a count") )   
        $OFS = ','   
        $gen = "<" + [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"       
        $list = [string](0..$($count-1) | %{ "T{0} {1}" -f $upperList[$_],$lowerList[$_] })   
        $argList = [string](0..$($count-1) | %{ $lowerList[$_] })   
        "public partial class Tuple {"   
        "public static Tuple$gen Create$gen($list) { return new Tuple$gen($argList); } "   
        "}"   
    }

Now just add a call to this function in Get-Tuple and the code is now inference friendly.

Next up is defining an interface for tuples that will allow us to treat a Tuple<2> as a Tuple<1>.  Both have an "A" property and should be able to be used in a generic way.


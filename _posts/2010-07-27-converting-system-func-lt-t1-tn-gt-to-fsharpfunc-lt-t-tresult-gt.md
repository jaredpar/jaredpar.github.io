---
layout: post
---
Interop of delegate style types between F# and other .Net languages is a pain
point that results from a fundamental difference in how delegates are
represented in the F# language.?? Typical .Net languages like C# see a delegate
as taking 0 to N parameters and potentially returning a value.?? F# represents
all exposed delegates as taking and returning a single value via the
[FSharpFunc<T,TResult>](http://msdn.microsoft.com/en-us/library/ee340302.aspx)
type.?? Multiple parameters are expressed by having the TResult type be yet
another [FSharpFunc<T,TResult>](http://msdn.microsoft.com/en-
us/library/ee340302.aspx).

This creates a host of problems calling exposed F# delegate / function types

  * Can???t use C# lambda expressions which take more than one parameter 
  * System.Func<> expressions of equivalent logical shape can???t be converted 
  * Method group conversions don???t work 

The only step is to introduce a conversion step when calling into F# code.?? F#
does provide a helper method in F# in the
[FSharpFunc.FromConverter](http://msdn.microsoft.com/en-
us/library/ee353520.aspx) method.?? But once again it???s only useful for
delegates of one parameter, anything higher requires a more in depth
conversion.?? For example here is the C# code to convert a 2 parameter delegate
into the equivalent F# type.

    
    
    public static FSharpFunc<T1, FSharpFunc<T2,TResult>> Create<T1, T2, TResult>(Func<T1,T2,TResult> func)


    {


        Converter<T1, FSharpFunc<T2, TResult>> conv = value1 =>


            {


                return Create<T2,TResult>(value2 => func(value1, value2));


            };


        return FSharpFunc<T1, FSharpFunc<T2, TResult>>.FromConverter(conv);


    }

Not very pretty or intuitive because the code needs to recreate the nested
style of F# func???s.?? This gets even more tedious and error prone as it gets
past 2 parameters.

The simplest solution, as is true with most F# interop scenarios, is to
leverage F# itself to define the interop / conversion layer.?? It already
naturally creates the proper nesting structure so why spend type redoing the
logic in C#.?? The logic can then be exposed as a set of factory and extension
methods to make it easily usable from C#.

    
    
    [<Extension>]


    type public FSharpFuncUtil = 


    


        [<Extension>] 


        static member ToFSharpFunc<'a,'b> (func:System.Converter<'a,'b>) = fun x -> func.Invoke(x)


    


        [<Extension>] 


        static member ToFSharpFunc<'a,'b> (func:System.Func<'a,'b>) = fun x -> func.Invoke(x)


    


        [<Extension>] 


        static member ToFSharpFunc<'a,'b,'c> (func:System.Func<'a,'b,'c>) = fun x y -> func.Invoke(x,y)


    


        [<Extension>] 


        static member ToFSharpFunc<'a,'b,'c,'d> (func:System.Func<'a,'b,'c,'d>) = fun x y z -> func.Invoke(x,y,z)


    


        static member Create<'a,'b> (func:System.Func<'a,'b>) = FSharpFuncUtil.ToFSharpFunc func


    


        static member Create<'a,'b,'c> (func:System.Func<'a,'b,'c>) = FSharpFuncUtil.ToFSharpFunc func


    


        static member Create<'a,'b,'c,'d> (func:System.Func<'a,'b,'c,'d>) = FSharpFuncUtil.ToFSharpFunc func

Now I?? can convert instances of System.Func<> to the F# equivalent by simply
calling .ToFSharpFunc().

    
    
    var cmd = Command.NewSimpleCommand(


        name,


        flagsRaw,


        func.ToFSharpFunc());

Much better.


---
layout: post
---
Not to long ago I received an email from a customer who wanted to report a bug
in the VB.Net debugger. They believed that there was a bug invoking ToString
on Integer types in the immediate window and provided the following sample as
evidence

    
    
    i = 100


    ? i


    100 {Integer}


        Integer: 100


    ? i.ToString("c02")


    {"Conversion from string "c02" to type 'Integer' is not valid."}


        _HResult: -2147467262


        _message: "Conversion from string "c02" to type 'Integer' is not valid."


        Data: {System.Collections.ListDictionaryInternal}


        HelpLink: Nothing


        HResult: -2147467262


        InnerException: {"Input string was not in a correct format."}


        IsTransient: False


        Message: "Conversion from string "c02" to type 'Integer' is not valid."


        Source: "Microsoft.VisualBasic"


        StackTrace: "   at Microsoft.VisualBasic.CompilerServices.Conversions.ToInteger(String Value)"


        TargetSite: {Int32 ToInteger(System.String)}

The customer expected the method Integer.ToString(String) to be invoked and
found the conversion to Integer to be a bug. Surprisingly to the user, and
several people on the team, this behavior is 'By Design' [1]. To understand
why we have to get a better picture of how exactly this is evaluated in the
immediate window. There are two particular areas of importance here.

  1. The static type of the variable **i **is Object not Integer. The first expression 'i = 1' declares a variable named **i **in the context of the debugger and assigns it the value 100. The ability to declare variables in the debugger predates type inference and uses Option Explicit Off semantics resulting in a type of Object for the variable
  2. The debugger does not inherit project settings for Option Strict and instead evaluates all expressions with Option Strict Off.

These two combine together to mean that almost every expression evaluated on a
variable declared in the immediate window will be done in a late bound
fashion. It also means the above code sample is most accurately represented
by the following real code.

    
    
        Sub Main()


            Dim i As Object = 100


            Dim result = i.ToString("co2")


        End Sub


    


    

Compiling and running that code will indeed cause the exact same exception as
viewed in the immediate window. But why?

Remember earlier I said that **almost** every expression would be evaluated it
a late bound fashion. The compiler will use late binding when it can't find a
suitable method to bind to statically and late binding is otherwise allowed.
In this case the type of the variable is Object and hence Object.ToString()
can be bound to statically and indeed that's what happens in this case.
Further in VB.Net it's possible to call a method that has no parameters
without parens: ex i.ToString is legal. This results in the ('c02') portion
of the expression being interpreted as an indexer expression into the
resulting string. Because Option Strict is off the compiler allows a silent
narrowing conversion between String and Integer. The result of all of this is
the code is actually evaluated as

    
    
        Sub Main()


            Dim i As Object = 100


            Dim result = i.ToString()(CInt("co2"))


        End Sub


    


    

I certainly found this interesting the first time I encountered it.

[1] Please don't confuse me saying an issue is 'By Design' with me thinking
the behavior is ideal. It's merely a statement that the behavior conforms to
the specification at the time of this writing.


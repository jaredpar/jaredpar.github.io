---
layout: post
---
One of my current hobby projects,
[VsVim](http://blogs.msdn.com/jaredpar/archive/2009/12/14/vsvim-update-
released-version-0-5-4.aspx), requires me to make a lot of calls between F#
and C# projects.?? The core Vim engine is a pure F# solution based on Visual
Studio???s new editor.?? It additionally has a small hosting layer and a large
test bed both written in C#.

When working with the exposed core Vim engine API, I???ve found a number of
generated F# constructs which are not easily accessible from C#.?? The problem
stems from the manner in which native F# types are exposed.?? Many of them are
generic and?? lack type inference friendly helper methods that force awkward
usage patterns in C#.?? Most painful is the FSharpOption<T> type because it???s a
type I frequently expose in APIs.

FSharpOption<T> is the exposed type for the native F#
[option](http://msdn.microsoft.com/en-us/library/dd233245\(VS.100\).aspx)
construct representing a value which may or may not be present. It???s similar
to C#???s nullable type except that it applies to all types of values.?? The
primary operations you want to do with an FSharpOption<T> are

  1. Create an option with a value 
  2. Create an option without a value 
  3. Determine if it has a value 
  4. Determine if it does not have a value 
  5. Access the value 

In F# using an option is an inherent part of the language and the hence the
resulting code is very elegant.

    
    
    let OptionExample = 


        let optionWithValue = Some(42)


        let optionWithoutValue = None


        let isSome = Option.isSome optionWithValue


        let isNone = Option.isNone optionWithoutValue


        Option.get optionWithValue

Unfortunately the equivalent C# code is not nearly so nice.

    
    
    static int OptionExample() {


        var optionWithValue = new FSharpOption<int>(42);


        var optionWithoutValue = FSharpOption<int>.None;


        var isSome = FSharpOption<int>.get_IsSome(optionWithValue);


        var isNone = FSharpOption<int>.get_IsNone(optionWithValue);


        return optionWithValue.Value;


    }

Too many explicit types!!!?? Using any explicit type with F# related code just
feels wrong.

In C#, and most other .Net languages, 4 out of the 5 operations you want to do
on FSharpOption require an explicit type parameter.?? This resulting code is a
bit tedious with a simple type like int but once you get to more complex
generics it can get extremely verbose.?? In the case of anonymous types, it???s
simply not possible to use the FSharpOption<T> without a few wrappers.

Luckily most of these can be solved by using the familiar pattern of using a
non-generic class with static generic methods.?? These allow C# users to take
advantage of the languages type inference capabilities to reduce the verbosity
of the code.

    
    
    public static class FSharpOption {


        public static FSharpOption<T> Create<T>(T value) {


            return new FSharpOption<T>(value);


        }


        public static bool IsSome<T>(this FSharpOption<T> opt) {


            return FSharpOption<T>.get_IsSome(opt);


        }


        public static bool IsNone<T>(this FSharpOption<T> opt) {


            return FSharpOption<T>.get_IsNone(opt);


        }


    }

Now we can rewrite the original sample a bit cleaner

    
    
    static int OptionExample() {


        var optionWithValue = FSharpOption.Create(42);


        var optionWithoutValue = FSharpOption<int>.None;


        var isSome = optionWithValue.IsSome();


        var isNone = optionWithoutValue.IsNone();


        return optionWithValue.Value;


    }

Notice we still haven???t fixed the None case.?? Fixing this is a beyond the
scope of what I want to write here but it is possible in certain scenarios.
You can take a look at how in one of my previous blog articles: [Function C#
Providing an
Option](http://blogs.msdn.com/jaredpar/archive/2008/10/06/functional-c
-providing-an-option.aspx).

This pattern is not just limited to the FSharpOption class but can be applied
to many of the generic constructs F# exports to wrap their native types.?? In
particular FSharpFunc<T,Result> and the various FSharpChoice<> types can be
made a bit friendlier with a few wrappers.


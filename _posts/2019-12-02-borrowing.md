---
layout: post
title: Exploring borrowed annotations in C#
tags: [c#, language design]
---
One request I see fairly often for C# is to add the concept of borrowed values. That is values which can be used but
not stored beyond the invocation of a particular method. This generally comes up in the context of features which 
require a form of ownership semantics like stack allocation of classes, `using` statements, resource management, etc ...
Borrowing provides a way to safely use owned values without complicated ownership transfer.

This is a feature we explored while working on System C# in the 
[Midori Project](http://joeduffyblog.com/2015/11/03/blogging-about-midori/) in the context of having stack like
allocations. The experiment was successful and brought with it significant performance wins for the system. But the 
experience also taught us quite a bit about the difficulties in introducing ownership concepts into languages and 
frameworks that didn't have them designed in from the start.

To help illustrate these difficulties this post is going to focus on what it would look like if borrowing were added
to C# for reference types. Borrowing, the concept of use but don't store, is a necessary pre-requisite for most forms
of ownership. Lacking borrowing the more desired features, like stack allocation of classes, wouldn't be possible. 

In this post borrowed references will be denoted with a `&` following the type name. So `Widget` is a normal reference 
while `Widget&` is a borrowed reference. There is a subtyping relationship between borrowed and normal references
meaning a `Widget` is convertible to a `Widget&` but not the other way around. This annotation can be applied to locals
and parameters. It cannot be applied to fields, return types, or parameters which are not `out`, `in` or `ref`. 

```cs
class Widget { 
    Widget Field;

    void Example(Widget normal, Widget& borrowed) {
        borrowed = normal;  // Okay: converting Widget to Widget&
        borrowed = this;    // Okay: converting Widget to Widget&
        normal = borrowed;  // Error: can't convert Widget& to Widget

        Field = normal;     // Okay: converting Widget to Widget&
        Field = this;       // Okay: converting Widget to Widget&
        Field = borrowed;   // Error: can't convert Widget& to Widget
    }
}
``` 

This simple system enforces that borrowed references have the desired "use but don't store" semantics. When a value is
passed to a borrowed parameter of a method, the caller can be assured that the value is no longer referenced at the
completion of the method. That is it cannot be stored into a field, used as a generic argument, returned or smuggled 
out via a `ref` / `out` parameter.

This system is limiting though because there is no way to invoke instance members on borrowed references. The `this`
reference in instance methods is a normal reference. Hence invoking an instance method on a borrowed reference would 
effectively be converting a borrowed reference to a normal one which breaks the model. To allow for method invocation 
we'll let methods mark the `this` reference as borrowed by adding a `&` after the method signature. Further any method
which overrides or implements a method where `this` is marked as borrowed must also be marked as borrowed.

```cs
abstract class Resource {
    // Method with a borrowed `this`
    public abstract void PrintStatus() &;

    // Normal method
    public abstract void Close();
}

class MyResource : Resource {
    bool Valid;
    public override void PrintStatus() & {
        Console.WriteLine($"Is valid {Valid}");
        MyResource r = this;    // Error: can't convert MyResource& to MyResource
    }

    public override void Close() {
        Valid = false;
    }

    static void Example(MyResoure normal) {
        MyResource& borrowed = normal;

        borrowed.PrintStatus(); // Okay
        normal.PrintStatus();   // Okay

        borrowed.Close();       // Error: can't call a normal method from a borrowed reference
        normal.PrintStatus();   // Okay
    }
}
``` 

So far this all seems pretty sensible. Borrowed values have the desired "use but don't store" semantics, have a clean
integration into the type system and have a minimal syntax burden.

What happens though when we attempt to leverage this feature in the .NET SDK? Consider as an example `string.Format`.
The parameters to this method are never stored and in practice are often a source of wasteful boxing allocations. This
is a classic scenario where borrowing should bring big wins. The parameters can be marked properly as borrowed and then
the runtime can safely stack allocate the boxing allocations.

```cs
class String {
    public void Format(string format, object& arg) {
        var strArg = arg.ToString();
        FormatHelper(format, stringArg);
    }
}
```

This example though also reveals a significant problem: the call `arg.ToString` is illegal because the definition 
`object.ToString` is not defined as having a borrowed `this` parameter. Worse is that the .NET team can't fix this by
going back and marking `object.ToString` as borrowed. This would be a massive compatibility break because every override
of `ToString` would likewise need to be marked as borrowed. 

This compat burden is where borrowing starts to fall down as a feature. It's not just limited to `ToString` but 
virtually the entire surface area of .NET. Borrowed values are significantly hampered because they ....

- Can’t call any methods on object `GetHashCode`, `ToString`, `ReferenceEquals`, `GetType` or `Finalize`
- Can’t call `operator==`, `!=`, etc …
- Can’t be used as generic arguments. So no `List<Widget&>`.
- Can't call any method on any interface defined in the .NET SDK surface area.

The non-virtual methods could be fixed by updating their annotation in the framework to be borrowed. The `virtual` 
methods and `interface` definitions though can't be changed as it would break compatibility. That means `object&` or 
any borrowed interface is by themselves is basically useless. They can't be stored as they're borrowed and no members
can be invoked on them.

This is a pretty significant problem. It means that a good portion of the .NET Framework API parameters can never be 
marked as borrowed because doing so would make the values unusable. That's true for `object`, interfaces or really any
unsealed type where virtual methods are used. This means large sections of .NET which are perfect for ownership
semantics can never take advantage of them. So much so that it brings up the question of whether this feature is 
worth doing. Successful uses of borrowing would require significant duplication of the .NET Framework surface area 
with the only real change being to add borrowing semantics to parameters. Not ideal.

This is the crux of the problem with retrofitting languages with core features like ownership. The problem isn't just 
extending a 20 year old language to understand ownership, it's also about extending a 20 year old SDK. Both present
challenges that need to be overcome. In the case of ownership though it's much more about whether the SDK could adopt 
it than whether it could be added to the language.

That's not to say the version of borrowing laid out in this post is complete. It's in fact lacking a number of features
that are necessary for a good borrowing system: relative lifetime annotations, borrowed fields, returning borrowed 
values, etc ... At the same time though those are all relatively solvable compared to the SDK compatibility issues.


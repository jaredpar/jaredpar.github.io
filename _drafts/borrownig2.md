---
layout: post
title: Exploring borrowed annotations in C# (part 2)
tags: [c#, language design]
---
One requesnt I see fairly often for C# is to add the concept of borrowed values. That is values which can be used but
not stored beyond the invocation of a particular method. This generally comes up in the context of features which 
require a form of ownership semantics like stack allocation of classes, `using` statements, resource management, etc ...

This a feature we explored while working on System C# in the 
[Midori Project](http://joeduffyblog.com/2015/11/03/blogging-about-midori/) in the context of having stack like
allocations. The experience taught us quite a bit about the difficulties in introducing ownership concepts into 
languages that didn't have them designed in from the start.

This post is going to explore the complications that arise when attempting to add borrowed values to C#. This will 
focus on the borrowing aspect only (use but don't store). Explicit ownership is a topic for another day.

In this post borrowed references will be denoted with a `&` following the name. So `Widget` is a normal reference 
while `Widget&` is a borrowed reference. There is a subtyping relationship between borrowed and normal references
meaning a `Widget` is convertible to a `Widget&` but not the other way around. 

For starters only locals, non-ref parameters, and `this` can be denoted as borrowed. Methods where `this` is borrowed
are denoted by having a trailing `&` after the method signature. If a `virtual` method is marked as `&` then all 
`overrides` must be marked is a `&` as well. 

Later we'll explore a bit what happens when fields, ref parametrs and returns can be borrowed. But for now this means
once a value is stored into a borrowed (`&`) location then that location can't ever escape the value so it lives 
beyond the execution of the current method.

Lets apply these rules to some real code to demonstrate their affect:

``` c#
class Widget {
    static Widget Instance;

    // Method with a borrowed this
    void Method() & { }

    void Example(Widget w) & {
        Widget& b = w;      // Okay: converting Widget to Widget
        w = b;              // Error: can't convert Widget& to Widget

        Instance = w;       
        Instance = b;       // Error: can't convert Widget& to Widget

        Console.WriteLine(w.ToString());
        Console.WriteLine(b.ToString()); // Error: can't call when `this` is Widget with receiver Widget&

        w.Method();
        b.Method();
    }
}
``` 

So far this all seems pretty sensible. The syntax burden is fairly light and the errors around attempted conversions
of `Widget&` to `Widget` are straight forward. The first inkling of where this gets dicey though is that 
the error on `b.ToString`. The definition of `object.ToString` does not have a borrowed `this` which means invoking
`ToString` is the equivalent of saying `object o = this`. This would allow a borrowed value to escape and hence is 
flagged as an error.

This problem can’t be fixed by going back and marking `object.ToString` as borrowed. That would be a breaking change for
every type out there which has a `ToString` override as none of them are borrowed. This compat burden extends well 
beyond `ToString` for borrowed values.

- Can’t call any methods on object `GetHashCode`, `ToString`, `ReferenceEquals`, `GetType` or `Finalize`
- Can’t call `operator==`, `!=`, etc …
- Can’t be used as generic arguments. So no `List<Widget&>`.
- Can’t be used as array elements.
- Think of any interface we’ve defined anywhere in .NET. They are useless in the face of borrowed references because 
zero of their methods have `this` marked as borrowed.

The non-virtual methods could be fixed by updating their annotation in the framework. The `virtual` methods and 
`interface` definitions can't be changed as it would break compat. That means `object&` is by itself only useful for
storing values as none of it's members can be invoked.

This is a pretty significant problem. It means that .NET Framework API parameters which invoke members on `object`
can't be marked as `object&` regardless of whether or not they escape the parameter. Concrete example here is 
`Console.WriteLine`. This is the conceptual definition of "use but don't store" but because it calls `ToString` the 
parameters can never be marked as `object&`. 

This is a pretty significant problem. It means the .NET Framework is very limited in where it can apply borrowing to 
parameters. Limited to the point that it questions whether the feature is useful at all. Successful uses of borrowing
would require significant duplication of .NET Framework surface area with the old real change being to use a new
object-like interface which had proper borrowing annotations.

This limitation alone is significant enough that it means general borrowing probably won't ever happen in .NET. But 
for the sake of exploration lets move past this. Lets imagine that .NET decided to break compat here and change the 
definition of `object` such that all its members were borrowed.




}. Further you're willing to duplicate all of the .NET Framework APIs you 
consume and rebuild them on top of your 
Once all this work is done you'll be able to thread borrowed references 
through the system. That experiment though will likely result in two conclusions:

1. Borrowed is a more logical default than non-borrowed. Assuming the 
That's a compat break though so you're stuck with manually
adding `&` everywhere.
1. 
- Two states (borrowed and non-borrowed) are simply not enough. You actually need to be able to describe the relative
 lifetimes of two arbitrary references.

To understand the second problem we need to actually start talking about linear types [1]. Or rather the most common 
use of linear types, variables which have a lifetime equal to the scope in which they are declared. Such variables can 
have really crisp RAII semantics, be allocated places other than the general heap, etc … For this email owned 
references will be denoted with a % following the name: example Widget%. There is a subtype relationship between 
Widget% and Widget&, but there is no type relationship between Widget% and Widget.

Given this I can now start to write some nice code:

``` csharp
void Owned() {
    Widget% w = new Widget();
    Widget& other = w;  // Ok
    w.M1(null);         // Okay
    w.M0();             // Error can't convert Widget% to Widget
}
``` 

The Widget instance “w” has a very well understood lifetime here that is strictly enforced by the language and the code 
reads pretty well. What happens though if we try and combine this with fields? It should be legal for one owned 
instance to wrap another so long as the lifetime of the wrapper is <= the item being wrapped.

``` csharp
class Bag {
    Widget& Widget;
}

void Fields() {
    Widget% W = new Widget();
    Bag% b = new Bag() { Widget = w } ;
}
```

The necessity of this feature became very apparent once we applied borrowing at scale in Midori. Lacking it we had 
methods that were taking 5+ borrowed parameters where in normal C# we would have just added a wrapper class.

This sample though just snuck in yet another feature: borrowed references in storage locations. This is where it 
gets tricky (assuming anyone read this far). At this point we have to accept that borrowed is not a binary 
decisions (borrowed and non-borrowed). Instead can only be described in relation to another objects lifetime. Just 
because a value has type Widget& doesn’t mean we can assign it to Bag.Widget. We can only do so iff the value is 
convertible to Widget& and has a lifetime >= the instance of Bag being assigned to.
 
``` csharp 
void Fun(Bag& b, Widget& w) {
    b.Widget = w;       // Error lifetime of 'b' may be less than 'w'
}
```

In order to have a fully functional type system we need to expand the notation for borrowed references to describe the 
relative lifetime of the reference. Lets do this by adding () after & and noting the object inside:
 
- Widget&(method) instances have a lifetime greater than or equal to the current method
- Widget&(any identifier) for example this, a local variable name, etc … instances have a lifetime greater than or 
equal to the variable being identified
- Widget&(heap) is equivalent to Widget. Heap denotes the GC heap which has the longest lifetime (until you can’t see 
it anymore).

Now we can go back and write the fun method correctly:

``` csharp
void Fun(Bag&(method) b, Widget&(b) w) {
    b.Widget = w;      
}

void Example() {
    Widget %w = ...;
    Bag% b = ...;
    Fun(b, w);     
    Fun(b, null);
    Fun(new Bag(), w); // Error: 'w' has a smaller lifetime than 'new Bag'
}
```

This is basically where the wheels start to fall off. These scenarios are not rare in C#, they are in fact extremely 
common. The syntax I’ve chosen here is deliberately ugly but there’s really nothing you can do here to make it prettier. 
All this extra stuff really only solved one of the initial problems I laid out. You can now have arrays of borrowed 
type and write some primitive non-generic collections.

Several may be reading this email and thinking “man this is looking a lot like rust”. Completely agree. The type 
system we came up with, feature wise, ended up looking a lot like what Rust has. Rust is successful here, where C# 
fails, because it was designed in from the start. Aliasing of objects is where most of the problems come along and the
design patterns of Rust reduce aliasing + has design patterns that fit naturally into the lifetime rules. C# is 
frankly addicted to aliasing, both explicit and implicit aliasing, and the patterns it uses tends to interact 
painfully with lifetime rules (that + the compat issues).

The conclusion we came to is essentially:

Yes you can add linear types to C# but the code you end up writing wouldn’t be recognizable by 99% of the C# developers 
out there. Or more succinctly you’ve basically invented a new language.

Note: didn’t spend time diving into the necessity for a move operator, constructor nightmares and parametric 
polymorphism in methods. 

[1] Yes yes, the email is about linear types and I had to bore you to tears with subtyping, funny & notations and 
operators before I would talk about linear types. 

** 

This blog post will explore what adding borrowing to C# would look like today. This will only focus on borrowing 
though and save 

One request I see fairly often for C# is to add the concept of borrowed values. That is to mark a specific variable
/ location as being able to use but never own. A borrowed value can be used but not stored away.  

One request I see fairly often for C# is to add some form of borrowed values into the language. 

This is a markdown rendering of a response I gave to the following question: 

> Why doesn't C# add support for linear types into the language?

It's a question that really comes down to borrowing which is a topic I've been meaning to write about for some time 
as we experimented a lot on it in Midori. Here is the original response I gave. Going to evolve this into a more 
reasonable post though. 

TLDR: Type systems must be designed with linear types in mind, they can’t be bolted on later.

We explored linear types, and the more general area of reference ownership semantics, a lot in Midori. Overall this 
area really comes down to the concept of borrowing. Essentially references which can be used but can’t be arbitrarily
stored / disposed.  The concept of “borrowing” is important for linear types because you need to be able to denote
places where the type lives vs. where the type is used. This is key to being able to pass instances around to methods
while not violating the linear lifetime semantics.

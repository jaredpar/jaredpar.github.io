---
layout: post
---
A tuple in computer science can be described as a set of name/value pairs.  In
some cases it can be described as simply a set of values that are accessible
via an index [1].  Previously I discussed how to create a [Tuple inside of
PowerShell](http://blogs.msdn.com/jaredpar/archive/2007/11/29/tuples-in-
powershell.aspx).  This series will focus on the use of Tuples in DotNet and
how to use PowerShell to generate DotNet code.

This series will also distinguish between mutable and immutable tuples.  As
DotNet is shifting it's focus on parallel programming, immutable types are
becoming more important.  Therefore this serious will focus on Tuples as
immutable types and later examine mutable tuples.

In Visual Studio 2005, both C# and VB acquired tuples as a part of the
programming language in the form of Anonymous Types.  These fit all of the
properties of a tuple.  The one difference is in VB, anonymous types are
mutable by default.  This can be changed though by using the **Key** keyword.

However anonymous types are lacking one quality which severely lessens their
usefulness.  [Their type cannot be
described](http://blogs.msdn.com/jaredpar/archive/2007/10/01/casting-to-an-
anonymous-type.aspx).  This prevents them from being used as parameters,
fields, generic parameters [2] etc ...  Unless you use late binding or
terribly awkward casts this is limiting.

To get around this, we will be defining a set of generic tuple class
supporting 1-N name value pairs.  The great downside is because we will be
predefining these types the names in the name value pair will be fixed.  We
will be using A-N for 1-N pairs.

This is very limiting in itself because it's reducing the expressiveness of a
type.  Anonymous types are much more expressive since they have names.  Now
types will have properties A,B, etc ...

For me this still works.  In my code, I only end up using tuples when I need
to pass data around between tightly coupled classes, or just within the same
class.   Since the creation and use are so close loosing the full
expressiveness of the name is not that limiting.

In addition, our tuple implementation will leverage type inference as much as
possible such that the following code can be written.

    
    
                var tuple = Tuple.Create("foo");


                Console.WriteLine(tuple.A);

Why write a script to generate these classes?  Wouldn't it just be easier to
just do this by hand'  Yes and no.  If you are doing a fixed set of short
used classes then yes, do it by hand.  These scripts evolved out of my use of
tuples.  Once I would settle on a structure and I would think of a new feature
I needed.  Typically I have tuples defined up to 5 fields.  Retyping out a new
feature got tiresome and error prone.  With a scripting solution I could add a
new feature and tests in just a few minutes.  The series is very
representative of the way my solution changed over time.  Simple at first but
I added features as the situation dictated.  Having a scripting solution saved
me a lot of time.

Next up, generating the basic structure.

[1] In this case, the index just becomes the name and hence a name/value pair.


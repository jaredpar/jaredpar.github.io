---
layout: post
---
Many developers want to implement equality functions for their objects.
DotNet made equality a deep part of the framework and added support all the
way up to System.Object with [Equals](http://msdn2.microsoft.com/en-
us/library/bsc2ak47.aspx) and [GetHashCode](http://msdn2.microsoft.com/en-
us/library/system.object.gethashcode.aspx).???? In addition to the strongly
enforced method semantics of GetHashCode and Equals there are also several
other hard to enforce patterns that developers must follow in order to
properly integrate into the rest of the DotNet framework.?? We'll explore those
rules today.

Before even talking about how to implement equality we need to define the
types of equality.

  * Reference equality: Are these two objects really the exact same object.??
  * Object/value equality: Depends on what the object author thinks equality means.?? Can be anything from reference equality up to, comparing fields, to were they created in the same app domain. 

In VB these are two very separate types of equality.?? Reference equality is
expressed through the "[Is"](http://msdn2.microsoft.com/en-
us/library/kb136x1y\(VS.80\).aspx) operator.?? Object equality is done directly
through operator=, operator<> and Equals.?? This is also indirectly exposed via
GetHashCode, EqualityComparer(Of T) and other framework patterns.

When implementing object/value Equality there are four methods that are
important to consider in order to fit expected patterns.?? What's even more
important is understanding which ones must be implemented together.?? If an
author overrides any of the functions in the following pairs they **must
**override both.

  * Equals/GetHashCode
  * Operator=/Operator!=

To make it easier, my rule of thumb is to override all four or none.

### Equals

This is the bread and butter of object/value equality.?? The author has free
reign to decide what is and what is not equal.?? However there are a few rules
authors must follow in order to fit into the rest of the framework.

  1. Do not throw an exception from Equals.?? Many components call Equals in a loop and there is no way for them to handle or recover from an exception.?? If the object is not equal just return False 
  2. The object passed in is typed to object.?? It is perfectly valid for the framework to pass in an object that is completely unrelated to the type defining Equals.?? The type author must account for and handle this case. 
  3. The framework can pass in Nothing as a parameter to Equals and this is valid.??

#2 and #3 may seem a bit off at first but it is implemented with a standard
pattern as seen below.

    
    
    Class C1


        Public Overrides Function Equals(ByVal obj As Object) As Boolean


            Dim other = TryCast(obj, C1)


            If other Is Nothing Then


                Return False


            End If


            ...


        End Function


    End Class

It's very important that you use "Is" to compare other in the above example.
Imagine if you slip up and type "=" instead.?? You're about to override
Operator= and this will cause "other=Nothing" to call operator=.?? If this is a
valid C1 instance operator= will almost certainly call Equals and then you'd
have a stack overflow.?? Our implementation of Operator= below will avoid this
problem.

### GetHashCode

This is both the easiest and trickiest function to override because it has
very subtle semantics which cause very hard to find bugs in code.?? The simple
rule is "If two objects are equal in the sense of value equality they must
return the same value in GetHashCode()".

Why??? Many classes use the hash code to classify an object.?? In particular
hash tables and dictionaries tend to place objects in buckets based on their
hash code.?? When checking if an object is already in the hash table it will
first look for it in a bucket.?? If two objects are equal but have different
hash codes they may be put into different buckets and the dictionary would
fail to lookup the object.

The better version of the GetHashCode rule has a small suffix on the simple
rule.?? "Only calculate the hash code based off of primitive fields which are
ReadOnly". This is not an absolute requirement as long as you are careful when
you are code.?? But as [previously
stated](http://blogs.msdn.com/jaredpar/archive/2008/03/24/part-of-being-a
-good-programmer-is-learning-not-to-trust-yourself.aspx), when coding it's
best not to trust yourself to do the right thing.?? Not doing this will get you
into trouble when dealing with Hashtables and dictionaries.

For instance take this not so small example.?? In this case value equality is
based solely off of Field1 which is a modifiable field.?? Once Field1 is
changed you may or may not be able to access the value in the dictionary
because GetHashCode() will change.?? This example is contrived but it does
happen in the real world and it can be incredibly difficult to track down.

    
    
    Class C2


        Public Field1 As Integer


    


        Public Sub New(ByVal f1 As Integer)


            Field1 = f1


        End Sub


        Public Overrides Function GetHashCode() As Integer


            Return Field1.GetHashCode()


        End Function


        Public Overrides Function Equals(ByVal obj As Object) As Boolean


            Dim other = TryCast(obj, C2)


            If other Is Nothing Then


                Return False


            End If


            Return other.Field1 = Field1


        End Function


    End Class


    


    Module Module1


    


        Sub Main()


            Dim map = New Dictionary(Of C2, String)


            Dim v1 = New C2(44)


            map.Add(v1, "avalue")


            Console.WriteLine(map(v1))


            v1.Field1 = 2


            Console.WriteLine(map(v1))  ' Potentially throws


        End Sub


    


    End Module


    

If Field1 were ReadOnly there would be no way to hit this problem.?? Then again
we'd also not be able to change Field1.

### Operator=

When implementing equality overriding operator= allows you to use the more
pleasant and reliable version of syntax comparison: a=b vs. a.Equals(b).?? I
say more reliable because using a.Equals(b) has an inherent dependency on "a"
being a non-Nothing object.?? "Operator=" makes no assumption and should
operate correctly in the presence of Nothing.

Operator= has virtually the same rules as Equals.?? Mainly don't throw from
operator=.?? Operator= is usually just defined in terms of Equals() and since
it also has to respect the no throw rule once we get there we are in good
shape.?? Getting to Equals() can be tricky though because one or both of the
arguments can be Nothing.?? In addition make sure not to use "=" to check for
Nothing because you're back to the stack overflow problem.

What's great here is there is a simple solution that you should use every time
you define Operator=.?? [EqualityComparer(Of T)](http://msdn2.microsoft.com/en-
us/library/ms132123.aspx) knows all of these rules and in the face of both
parameters being non-Nothing will call Equals() just like we want.?? This makes
the definition of Operator= boiler plate (I define very Operator= the exact
same way)

    
    
    Public Shared Operator =(ByVal left As C2, ByVal right As C2) As Boolean


        Return EqualityComparer(Of C2).Default.Equals(left, right)


    End Operator

What's even better is that EqualityComparer(Of T) understands the stack
overflow problem which can occur in equality comparison and avoids it.

### Operator <>

Operator<> has the same rules as Operator= and luckily the same easy type of
answer.

    
    
    Public Shared Operator <>(ByVal left As C2, ByVal right As C2) As Boolean


        Return Not EqualityComparer(Of C2).Default.Equals(left, right)


    End Operator

### Wrapping Up

I started this article thinking it would be a few paragraphs of simple rules.
But as I kept going I kept remembering the subtleties and problems I
encountered in the past.

For my own projects I avoid implementing equality unless it's truly needed
because of the problems with properly implementing GetHashCode().?? The one
exception is when I define immutable objects.?? Immutable objects have no
problems with GetHashCode() since they are unchangable so Equality is straight
forward.


---
layout: post
---
Recently we had a good discussion on an internal alias about the use of Me,
MyClass and MyBase in VB.  Me, MyBase and MyClass are all ways to access
instance member data in a VB class or structure.  There was a little bit of
confusion on the actual workings and meanings of the keywords in various
contexts and I want to use this post to shed light on the different meanings.

### The Basics

The keywords are used to alter the way in which instance members of a
class/structure are accessed.  In particular they affect the way
Overridable/MustOverride/Overrides functions are evaluated. Methods defined
with Overridable/Overrides/MustOverride are defined as virtual by the CLR.
For the purpose of this post all of these definitions are mostly equal.  This
discussion will be useless without and example so here's the code to discuss.

    
    
    Class GrandParent


        Public Overridable Sub Sub1()


            Console.WriteLine("GrandParent.Sub1")


        End Sub


    End Class


    


    Class Parent


        Inherits GrandParent


        Public Overrides Sub Sub1()


            Console.WriteLine("Parent.Sub1")


        End Sub


    End Class


    


    Class Child


        Inherits Parent


        Public Overrides Sub Sub1()


            Console.WriteLine("Child.Sub1")


        End Sub


    End Class

In this case Sub1 is a virtual method and there are three instances of it (one
per class).  By default virtual methods are called based on the runtime type
of the object.  The CLR will essentially walk the hierarchy from current type
to object looking for the first class which defines a particular method and
call that version.  It doesn't matter what the variable type is declared as,
just what type it actually is.

    
    
    Dim v1 As GrandParent = New Parent


    v1.Sub1()   ' Calls Parent.Sub1


    Dim v2 As GrandParent = New GrandParent


    v2.Sub1()   ' Calls GrandParent.Sub1

### Changing the call

If the CLR will always call a virtual Sub/Function based on the runtime type
of an object how can I access the parent function?  This is where MyBase comes
in.  MyBase allows you to call the version of the virtual method defined in
the parent class.  Essentially it tells the CLR call this method/property as
if my runtime type was my base type.

    
    
    Class Child2


        Inherits Parent


        Public Overrides Sub Sub1()


            MyBase.Sub1()   ' Calls Parent.Sub1


            Console.WriteLine("Child2.Sub1")


        End Sub


    End Class


    

MyClass is similar to MyBase.  Instead of telling the CLR the current type is
the base type, it tells the CLR the runtime type is the type where MyClass is
used.  This allows developers to call their type's version of a virtual method
no matter who derives from them.  In the following example it doesn't matter
how many, or who derives from Child3, Sub2 will always call the version of
Sub1 defined in Child3.

    
    
    Class Child3


        Inherits Parent


        Public Overrides Sub Sub1()


            Console.WriteLine("Child3.Sub1")


        End Sub


        Public Sub Sub2()


            MyClass.Sub1()


        End Sub


    End Class

### So, why not MyChild?

The short answer is, it's not verifiable.  When writing MyBase we can verify
that indeed there is a sub/function/property matching the call site in the
base class.  If no such method exists it will result in an error.  MyClass is
similarly easy to verify.  With MyChild however there would be no useful way
of guaranteeing a particular sub/function/property was defined on the child
class.

One way you can verify a child class contains a particular
property/sub/function is to make it MustOverride.  However in this case there
is no actual definition in the original type.  In fact, if you try and access
a MustOverride method with MyClass it will generate a compile time error.
Therefore every call must at least occur in the child class or lower rendering
MyChild superfluous.

### What about non-virtual methods and properties?

The primary intent of MyBase/MyClass is to call virtual methods in a non-
virtual way.  However they can also be used to call non-virtual methods.  From
the perspective of the user calling a non-virtual method with
MyBase/MyClass/Me has no discernable difference.  If you crack open the
generated IL you can see a small difference in the op code but the short story
is it won't affect your program.


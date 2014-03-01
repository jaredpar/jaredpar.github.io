---
layout: post
---
I've recently run across several APIs that have a dependency on only dealing
with objects that are serializable (in the binary sense). Unfortunately
determining if an object is serializable is a non-trivial task and rife with
problems. These problems have a direct impact on the types of guarantees
these APIs can make.

For all objects which are serializable, it's only possible to prove that a
very small subset of them actually are in code. Easier but less reliable
tests are very easy to write. So APIs must make a trade off. Only accept
instances of types which are provable serializable and miss out on a while
class of objects. Or do a much less reliable check and open themselves up to
failure further down in the algorithm.

Take System.Exception for example. It is possible to associate arbitrary data
with an exception through the [Data](http://msdn.microsoft.com/en-
us/library/system.exception.data.aspx) property. Associated just any object
with Exception is problematic though because Exceptions [should be serializabl
e](http://winterdom.com/weblog/2007/01/16/MakeExceptionClassesSerializable.asp
x). In order for an Exception instance to store these objects and remain
serializable, the objects must also be serializable. Since serializability is
not provable, the authors of Exception had to make a trade off between an
overly restrictive test, or a loose test. They chose the latter. As a result
it's impossible to determine before hand if a given Exception instance is
actually serializable.

Why is this the case though that serialization is tough to determine' Lets
start with what it takes to make a type serializable. There are two separate
components

  1. Declaring that the type is Serializable by either having the SerializableAttribute on the class definition or by implementing ISerializable 
  2. Making the type conform to the rules of serialization.

These are completely separate actions. It's possible to have types which do
any combination of the above but not both. Take for instance the following
type declarations

    
    
    [Serializable]


    class DeclaredOnly {


        private ConformsOnly m_conforms;


    }


    


    class ConformsOnly {


        private string m_name;


    }

Both of these types are legal C# code and both represent one of the two
extremes listed above. Yet neither of these types are actually serializable.
ConformsOnly is not because it has not actually declared itself to be
serializable. DeclaredOnly is not because one of it's members is not
serializable.

Lets look at proving serialization by ensuring types follow both of the rules.
Proving the first part of serialization is pretty straight forward. Simply
check to see if a type implements ISerializable or is decorated with the
Serialization attribute. The latter is directly supported in the type system
via [Type.IsSerializable](http://msdn.microsoft.com/en-
us/library/system.type.isserializable.aspx). This property is also the source
of the most common mistake I see with respect to determining if an object is
serializable. Take the following code snippet for an example.

public static voidExample1(object o) {  
'' if(o.GetType().IsSerializable) {  
''''?? // Do something different  
'? }  
}

On the surface, this looks like reasonable code. But as we just pointed out,
the property IsSerializable just determines the presence or absence of the
Serializable attribute but nothing about the second part. A more descriptive
attribute name would be IsSerializableAttributeDeclared. Yet many pieces of
code attempt to equate this property with the ability to be serialized (A fun
experiment here is to search for it's use in Reflector)

Proving the second part involves two cases, types implementing ISerializable
and types decorated with the Serializable attribute. Lets start with the
attribute. Proving these is involved but a straight forward process. The
type must '

  1. Be decorated with the Serializable Attribute 
  2. One of the following items must be true for every field at all points in the hierarchy 
    1. It must be decorated with the NonSerializedAttribute 
    2. The type of the field must be sealed and must conform to all of these rules 

Instances of types which meet these guidelines will always be serializable.
Not meeting these rules though does not exclude a type from serialization.
There are several sets of types decorated with Serializable which are
serializable and do not meet these rules.

Take for instance types that violate rule 2.2. By having a field whose type
is not sealed, it is possible to construct a runtime instance which contains a
value whose type is not serializable. The following type fits into this
category.

    
    
    [Serializable]


    class OnlyKnownPerInstance {


        private object m_field1;


    }

Whether or not an instance of this type is serializable depends on the value
of m_field1. So the only way to prove it is serializable is to look at the
runtime information. This makes any definitive analysis on the type
impossible. The actual object must be inspected.

The other case to examine are types implementing ISerializable. Serialization
is a custom task for instances of these types and is done in imperative code.
Proving these types are serializable involves actual algorithm inspection and
is beyond the scope of this blog post. But suffice to say, proving these are
serializable is an order of magnitude more difficult.

Getting back to the crux of this article. What is the best way to determine
if an object is serializable or not' Bottom line, there is no good way. The
only 100% definitive way is to serialize the object and see if it succeeds or
not. This is problematic because it is not future proof. It only tells you
that the object **was **serializable. This is a very important distinction.
It's possible for the object to be mutated in a different state later on which
will prevent it from being properly serializable.

If serialization of a parameter is very important to the semantics of an API
this is the only way to ensure the semantics are not violated is to serialize
the object immediately and store the binary data. Otherwise you can only make
a loose guarantee that an attempt to serialize in the future will succeed.


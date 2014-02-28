---
layout: post
---
This is a bit of a follow up to a [previous
post](http://blogs.msdn.com/jaredpar/archive/2008/04/28/properly-implementing-
equality-in-vb.aspx) we discussed how to properly implement equality in VB.
Several users commented/asked that [IEquatable(Of
T)](http://msdn.microsoft.com/en-us/library/ms131187\(VS.80\).aspx) could be
used in place of overriding Equals().  Since [IEquatable(Of
T)](http://msdn.microsoft.com/en-us/library/ms131187\(VS.80\).aspx)  doesn't
define a GetHashCode() method the user didn't need to define it and hence run
into all of the problems associated with GetHashCode() usage.

Unfortunately this is not the case.  Several parts of the framework link
IEquatable(Of T).Equals and Object.GetHashCode() in the same way that
Object.Equals() and Object.GetHashCode() are linked.

The prime example of this is [EqualityComparer(Of
T)](http://msdn.microsoft.com/en-us/library/ms132123.aspx).  This class is
used to provide instances of IEqualityComparer(Of T) for any given type.
Under the hood it tries to determine the best way checking for equality in
types.  If T implements IEquatable(Of T) it will eventually create an instance
of GenericEqualityComparer(Of T) [1].  The methods of IEqualityComparer(Of T)
are implemented as follows (boundary cases removed)

  * Equals(left, right): return left.Equals(right) 
    * Equals in this case is IEquatable(Of T).Equals
  * GetHashCode(obj): return obj.GetHashCode()

This implicitly links IEquatable(Of T).Equals to Object.GetHashCode().
Therefore if you implement IEquatable(Of T) you should also override
GetHashCode().  The best way to view this is "if you implement IEquatable(Of
T) you should override Equals and GetHashCode."

What's even more unfortunate is there is no feedback to indicate this
relationship exists.  If you override Equals or GetHashCode both the C# and VB
compilers will issue a warning/error.  Implementing IEquatable(Of T) produces
no such warning.

[1] Unfortunately this is a private type so you will need to use Reflector to
view the type.


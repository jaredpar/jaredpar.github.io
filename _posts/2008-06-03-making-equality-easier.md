---
layout: post
---
Recently I've done a bit of posting about the difficulties of [properly implementing equality]({% post_url 2008-05-12-equality-isn-t-easy %}) [in VB]({% post_url 2008-04-28-properly-implementing-equality-in-vb %}) (and DotNet in general).  While most of the problems can be fixed with a standard snippet the one really hard to implement issue is GetHashCode().  The rules for GetHashCode() are both simple and seemingly contradictory

  1. If two objects are equal (via Equals) their GetHashCode() should be equal
  2. GetHashCode() shouldn't ever change 

These rules imply that GetHashCode() is related to Equality.  At a fundamental level though GetHashCode has nothing to do with Equality.  Instead it is linked to bucketing and ultimately any hashing sturcture such as Dictionary, Hashtable, etc ...

Unfortunately it is impossible to separate these two from an API perspective because it is ingrained into the BCL.  There is a way to separate this out at a functionality level and still satisfy all of the rules of the GetHashCode() and Equals()

``` vbnet
Public Overrides Function GetHashCode() As Integer
    Return 1
End Function
```

This absolutely maintains both of the rules for GetHashCode().  This allows you to completely separate Equality and GetHashCode() in your implementation while not breaking any BCL rules or assumptions.

Of course this does come with a trade off.  As said before GetHashCode() is primarily used as a bucketing mechanism.  It will cause the performance of bucketing collections such as Dictionary or Hashtable to drop from close to O(1) to O(N).  But once again this is not a bug but a conscious trade off.


---
layout: post
---
In responding to a recent [blog post](http://blogs.msdn.com/jaredpar/archive/2008/12/10/immutable-collections-and-backwards-compatibility.aspx), one of the readers, Jeremy Gray, noted that I was using a [NotImplementedException](http://msdn.microsoft.com/en-us/library/system.notimplementedexception.aspx) where I should have been using a [NotSupportedException](http://msdn.microsoft.com/en-us/library/system.notsupportedexception.aspx). At first I did not agree.  There was a method on an interface which my underlying object could not implement therefore I felt the choice of [NotImplementedException](http://msdn.microsoft.com/en-us/library/system.notimplementedexception.aspx) was an appropriate.  

However I was also not very familiar with [NotSupportedException](http://msdn.microsoft.com/en-us/library/system.notsupportedexception.aspx) and decided to investigate a bit more. After all, part of the fun of blogging is being wrong in a very public fashion and this was certainly a golden opportunity. The post was commenting on API design, what better way to be wrong than with a different API design issue?

After doing a bit of research I agree with Jeremy and draw the following distinction between the two exception types

* [NotSupportedException](http://msdn.microsoft.com/en-us/library/system.notsupportedexception.aspx): Throw this exception when a type does not implement a method for which there is a corresponding property indicating whether or not the method in question is supported.  For Example:
    * IColletion<T>.Add -> IsReadOnly 
    * Stream.Seek -> CanSeek 
    * Stream.Write -> CanWrite 
* [NotImplementedException](http://msdn.microsoft.com/en-us/library/system.notimplementedexception.aspx): Throw this exception when a type does not implement a method for any other reason. 

For Example: ICollection.Count, ICloneable.Clone, etc ... [^1]

The method in question on my previous blog post was ICollection<T>.Add(). I was dealing with an immutable collection for which Add is not possible. Since there is a property, IsReadOnly, which serves as an indicator that Add() is not allowed, [NotSupportedException](http://msdn.microsoft.com/en- us/library/system.notsupportedexception.aspx) is the better choice.

[^1]: Not implementing these methods is likely a bad idea.


---
layout: post
---
We've heard feedback from several customers regarding the way certain types are displayed in the Debugger.  Many of the displays exist to maintain the user experience between versions of Visual Studio.  We constantly evaluate if this is the correct choice for a given version of the product.

Starting with VS2008, you don't have to wait for us any longer.  In VS2008, VB added full support for many of the debugging features it lacked compared to C# in 2005.  In particular we've added full support for the [DebuggerDisplayAttribute](http://msdn2.microsoft.com/en-us/library/system.diagnostics.debuggerdisplayattribute.aspx).  

By attributing a class or member with this attribute you can control how it is displayed in the debugger.  For each column (name, value and type) you can provide an alternate string or expression to display.  

The best part about this attribute is you can target types that exist in different libraries.  You don't even need the source for them.  One of the members in the Type field which species the target type.  Customizing a type in a separate library requires slightly more work than customizing a type you have the source for.  For a source project you can just apply the attribute directly to the type or member and it will display.  For a type in another library you need to do the following.

* Define a class library and include all of the [DebuggerDisplayAttribute](http://msdn2.microsoft.com/en-us/library/system.diagnostics.debuggerdisplayattribute.aspx) you want.  Make sure to apply the attributes to the assembly and specify the [Type](http://msdn2.microsoft.com/en-us/library/system.diagnostics.debuggerdisplayattribute.type.aspx) member.  Ex.

> <Assembly: DebuggerDisplay("{ToString}", Target:=GetType(Guid))>

* Place the built library under the folder "Visual Studio 2008\Visualizers" which is under your my documents folder. 

After doing this any Guid type will now show up as the actual Guid String ("10f3c4eb-7c0f-41b1-ae83-8838ff2f4f70") instead of {System.Guid}


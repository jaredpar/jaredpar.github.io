---
layout: post
---
Boolean value types are a constant source of problems for people attempting to
generate PInvoke signatures.  It's yet another case of managed and native
types differing on size.

There are two common boolean types in native code: bool and BOOL.  As with
most PInvoke issue the main issue is to understand the size

  * bool: 1 byte 
    * bool SomeOperation();
  * BOOL: 4 bytes
    * BOOL SomeOtherOperation();

Fortunately there is only one managed boolean type.  Unfortunately though, it
has 2 sizes that must be considered.  In managed code a bool is a single byte.
Yet the default marshalling for a bool will expand it to 4 bytes.  So even
though bool is 1 byte in managed code, it is by default compatible with the 4
byte native version BOOL.  

Translating a PInvoke signature for a native 1 byte bool is simple enough
though.  The [UnmanagedType](http://msdn.microsoft.com/en-
us/library/system.runtime.interopservices.unmanagedtype%28VS.80%29.aspx).I1
value allows for this scenario.  It tells the CLR that while the managed code
has a boolean value the corresponding native item is the 1 byte version of
bool.  The CLR will then make the necessary size adjustments.  When converting
native -> managed it will consider a non-zero value true and 0 to be false.

Native:

> bool SomeOperation();

Managed:

    
    
    [return: MarshalAs(UnmanagedType.I1)]  
    public static extern bool SomeOperation();

BOOL's can be usefully marshalled in two different ways.  The first is simply
as a int (signed or unsigned).  This works because int matches the size
requirement of a BOOL and the sign is not really important as true or false is
simply 0 or not 0.

    
    
    public static extern int SomeOtherOperation();

This is certainly sub-optimal since we're now returning a non-boolean type for
what is intended to be a boolean operation but some people choose to Marshal
it this way.  

Marshaling a native BOOL to a managed bool works without any annotations.
However it is preferred that you include the annotations to make it much
clearer what the native data type is.  The
[UnmanagedType](http://msdn.microsoft.com/en-
us/library/system.runtime.interopservices.unmanagedtype%28VS.80%29.aspx)
enumeration contains a Bool value for just this purpose.  This can be applied
to any managed bool return or parameter.  

    
    
    [return: MarshalAs(UnmanagedType.Bool)]  
    public static extern bool SomeOtherOperation();

And presto, we have maintained the boolean semantics of the operation.

Hint: If you are using the [PInvoke Interop
Assistant](http://www.codeplex.com/clrinterop), it will automatically do these
conversions for you.

**Edit**

Fixed a mixup on the default native size of bool.  Thanks to Jachym Kouba for
pointing out the mistake  


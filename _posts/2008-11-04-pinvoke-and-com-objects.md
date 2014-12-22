---
layout: post
---
I've occasionally found the need to mix COM interop and PInvoke. For certain scenarios it's just easier to code up a PInvoke declaration and function.  It's perfectly legal to include COM objects in these scenarios provided the appropriate Marshal attributes are added to the signature.  

The easiest way to accomplish scenario is to have the native signature only expose IUnknown instances. On the managed side use an object declaration annotated with MarshalAs(UnmanagedType.IUnknown). Example:

``` csharp
[DllImport("SomeDll.dll")]
[return: MarshalAs(UnmanagedType.IUnknown)]
public static extern object GetSomeComObject();
```

One item to remember though is how to managed the ref counting in this scenario. In any case where a COM object is considered to be coming out of the PInvoke signature, the CLR will assume that it has an obligation to call IUnknown::Release() at some point in the future. The corresponding native code must take this into account and appropriately AddRef() the object.  

This includes any scenario, as displayed above, where the COM object is the actual return value of the function [^1].

[^1]: Got bit by this last week.


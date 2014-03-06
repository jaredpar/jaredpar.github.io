---
layout: post
---
A common PInvoke question is how to deal with a double pointer. More specifically, how can one dereference an IntPtr to another pointer without using unsafe code?

Dereferencing a double pointer is done the same way a dereference to any other structure is done: [Marshal.PtrToStructure](http://msdn.microsoft.com/en-us/library/4ca6d5z7.aspx). PtrToStructure is used to transform a native pointer, in the form of an IntPtr, into a managed version of the native data structure the native pointer points to.

In the case of a double pointer, the native data structure the pointer points to is just another native pointer. The managed equivalent is the IntPtr (or UIntPtr) class.

For Example, say we had the following native data signature

{% highlight c %}
void GetDoublePointer(int** ppData)
{% endhighlight %}

This function returns a pointer to a pointer that points to an int.  (Pointer->Pointer->int). We can then use the following C# code to access the final int value.

{% highlight csharp %}
[DllImport("PInvokeSample.dll")]
static extern void GetDoublePointer(IntPtr doublePtr);

static void Main(string[] args)
{
    var ptr = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(IntPtr)));
    try
    {
        GetDoublePointer(ptr);
        var deref1 = (IntPtr)Marshal.PtrToStructure(ptr, typeof(IntPtr));
        var deref2 = (int)Marshal.PtrToStructure(deref1, typeof(int));
        Console.WriteLine(deref2);
    }
    finally
    {
        Marshal.FreeHGlobal(ptr);
    }
}
{% endhighlight %}


---
layout: post
---
Just as native pointer types are moved around with pointer arithmetic in native code, it can also be useful to move IntPtr types around in managed code. Say for instance there is an IntPtr available which points to a native array of Dog instances. To access the values of that array individually requires pointer arithmetic of a fashion.

For the most part this is a straight forward operation if the underlying native memory is understood. Say there is an array of Dog instances with length 10 and the Dog structure has a size of 8. The total amount of memory will be 80 bytes and with a valid dog instance being available at every 8 bytes. So if the start address is 1000 then 1000,1008,1016 and so on will point to a valid instance.

The native size of any data structure can be calculated via Marshal.SizeOf(tyepof(Dog)) [^1]. With a pointer to the start of the array, the Nth Dog instance can be accessed with a pointer of address = (N*sizeof(Dog))+startAddress

The address of a pointer can be accessed by 1 of 2 functions

  1. .ToIn32() 
  2. .ToInt64() 

Unless you are writing an application that will every only run on a 32 bit system, **don't use method #1** (even then still don't). Native pointer addresses vary in size depending on version of the OS a program is running on.  64 bit systems have a much larger address size (long vs int). Consequently calling .ToInt32 on a 64bit system will truncate the actual address to a valid that is no longer valid. This will eventually lead to a random error PInvoke'ing a function that is difficult to track down.

Instead use .ToInt64(). This method is safe on both 32 and 64 bit systems.  Additionally constructing an IntPtr instance with either value is safe. The class knows what version of windows it's executing on and will adjust the size in a safe way [^2].

In many of my projects I define a class similar to the following to take care of this automatically.

{% highlight csharp %}
public static class IntPtrExtensions
{
    public static IntPtr Increment(this IntPtr ptr, int cbSize)
    {
        return new IntPtr(ptr.ToInt64() + cbSize);
    }

    public static IntPtr Increment<T>(this IntPtr ptr)
    {
        return ptr.Increment(Marshal.SizeOf(typeof(T)));
    }

    public static T ElementAt<T>(this IntPtr ptr, int index)
    {
        var offset = Marshal.SizeOf(typeof(T))*index;
        var offsetPtr = ptr.Increment(offset);
        return (T)Marshal.PtrToStructure(offsetPtr, typeof(T));
    }
}
{% endhighlight %}

[^1]: It's highly advisable to not calculate this value yourself.

[^2]: See the post '[Is IntPtr(long) truncating?]({% post_url 2008-10-28-is-intptr-long-truncating %})' for more details


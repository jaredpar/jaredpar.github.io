---
layout: post
---
Recently after I made my original post titled 'PInvoke with 32 and 64 bit', a
developer emailed me.  They pointed out that there is an internal structure
that dynamically resizes based on the architecture; IntPtr.  IntPtr will be
size of the native chip pointer value.  So for values like size_t that map to
the pointer size, you can use the Address field of IntPtr.

This approach has some small down sides.

  1. The type you are marshaling must have the same size as IntPtr for all of the architecture's you run on 
  2. If you expose an interop API that uses IntPtr in this manner, you have to find a good way to inform your users that they really need to pass the value in the address of the IntPtr 

A way to get around #2 is to define your own type (like I did with SizeT) and
just wrap an IntPtr. If you have no other fields in your type it will Marshall
like an IntPtr. You can provide friendly properties that assign values into
the IntPtr's Address property.

If you have a type who's size does not change in the same way as IntPtr then
you'll probably have to go the custom marshal route


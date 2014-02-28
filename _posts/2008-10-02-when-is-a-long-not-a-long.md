---
layout: post
---
Answer: When PInvoke is involved.

I ran across a common error today on
[stackoverflow](http://stackoverflow.com/questions/148856/using-pinvoke-
correctly#150019) regarding P/Invoke that is worth blogging about.  The
question regarded the translation of a native API with a parameter of type
LONG.  The user mistakenly used the .Net long type as the parameter.  The
error is that a C++ LONG is not the same as a .Net long.

When talking about types and PInvoke it's easier to discuss byte size and
signed-ness than type names.  Otherwise confusion around long and short crop
up.  Really there are four integer byte sizes each of which can be signed or
unsigned: 1,2,4 and 8

The problem the user encountered is the C++ long is 4 byte signed and .Net
long is 8 byte signed.  PInvoke requires the parameters to have the same size.
Below is a quick table of the various types in C++ and .Net.

  * 1 byte
    * C++ - char, __int8, BYTE, BOOLEAN
    * .Net - byte
  * 2 byte
    * C++ - wchar, __int16, short, WORD
    * .Net - char, short
  * 4 byte 
    * C++ - int, LONG, long, __int32, DWORD
    * .Net - int
  * 8 byte
    * C++ - __int64, LONGLONG, DWORDLONG, LARGE_INTEGER
    * .Net - long

Based on this table when translating a C++ LONG, you should use a .Net int.

Edit1: Moved C++ short to 2 byte, added several other C++ types. (thanks
Raymond)


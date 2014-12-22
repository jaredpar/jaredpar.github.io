---
layout: post
---
While investigating a crash during a suite run I found the stack walk included the destructor for a [CComAutoCriticalSection](http://msdn2.microsoft.com/en-us/library/50yhb8t7.aspx).  This is a fairly reliable class so I immediately suspected my code.  I did a couple of quick checks for a double free and didn't find any.  Then I looked a little closer at CComAutoCriticalSection and spotted that it doesn't redefine the standard copy and operator= constructor.

This is a red flag for any class that implements RAII.  C++ will automatically define a copy/operator= for your clasess which will amount to a memcpy.  This means copies of two objects will be managing the same resource.  Once the second one is destroyed it will result in a double free and hopefully a crash.

I walked the hierarchy and discovered that none of the base classes redefined these methods either.  After that it only took a few minutes to discover the bug.  I attempt to pass the object by reference but instead ended up passing it by value.

To ensure I didn't miss any other cases of this, I added the following definition to my code base and moved all instances of CComAutoCriticalSection to point to this version.

``` c++
class SafeCriticalSection : public CComAutoCriticalSection
{
public:
    SafeCriticalSection() {}
private:
    SafeCriticalSection(const SafeCriticalSection&);
    SafeCriticalSection& operator=(const SafeCriticalSection&);
};
```

It should be standard practice to define all 3 of the above methods on any class which has RAII semantics.  This is not necessary if all of the members are copy safe (CComPtr<> for example).


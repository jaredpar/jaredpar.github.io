---
layout: post
---
This is a follow up for my [previous post]({% post_url 2007-10-16-c-new-operator-and-placement-new %}) about operator new and placement new.  This post will discuss the role of adding a custom allocator and using it with new.

It's handy to use custom allocators in C++.  Certain operations can be done more efficiently on a different type of allocator than the rest of your program.  It also allows you to add custom heap tracking, debugging, etc ...  C++ also makes it very easy to use.

The placement new operator already makes it fairly easy to use a custom allocator with your normal C++ syntax.  For example, the bellow code snippet displays how to use a custom allocator with the placement new operator.  You may or may not have to define the overloaded "new" depending on your code
base.

    
``` c++
    static inline
    void * _cdecl operator new(size_t cbSize, void* pv)
    {
        return pv;
    }
    
    void SomeProcedure()
    {
        MyCustomAllocator allocator;
        void *memory = allocator.Alloc(sizeof(Student));
        Student *p = new (memory) Student();
    }
```

However this code is a bit clunky.  It requires an extra local variable and an extra sizeof every time you want to use this pattern.  You could eliminate the local by placing the allocation call directly within the new () arguments but for longer type names this would make your lines very long.  

A more elegant solution is to further overload operator new.  Don't forget it's just a normal function (with a few restrictions).  That being said you can add an overload that takes in a reference to your allocation engine and perform the allocation inline.

``` c++
static inline
void * _cdecl operator new(size_t cbSize, MyCustomAllocator &allocator)
{
    return allocator.Alloc(cbSize);
}

void SomeOtherProcedure()
{
    MyCustomAllocator allocator;
    // ...
    Student *p = new (allocator) Student();
}
```

This is much more elegant, removes the need for a local variable and only adds the length of the allocator name to your normal line length.


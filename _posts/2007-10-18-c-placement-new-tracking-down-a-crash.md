---
layout: post
---
See my previous two posts on an introduction to placement new if you are unfamiliar with the subject.

  * {% post_url 2007-10-16-c-new-operator-and-placement-new %}
  * {% post_url 2007-10-17-c-placement-new-and-allocators %}

Recently I did a bit of work on the heap management story for our code base.  Mainly it was a change to unify the different ways we accessed our internal heap.  In the process I unified our operator new story.  Part if this involved unifying our placement new allocation overloads.  We have several allocators in our code base and I noticed we had several overloads which essentially did the same operation

    
{% highlight c++ %}
static inline
void * _cdecl operator new(size_t cbSize, MyCustomAllocator &allocator)
{
    return allocator.Alloc(cbSize);
}

static inline
void * _cdecl operator new(size_t cbSize, MyCustomAllocator *allocator)
{
    return allocator->Alloc(cbSize);
}
{% endhighlight %}
    
This seemed a bit redundant to me so I deleted the one which contained a pointer overload.  A while later I tested my changes and our application almost immediately crashed.  It only took a few minutes to discover the problem.  We had a lot of operations that followed this pattern.  
    
{% highlight c++ %}
Student *p = new (pAllocator) Student();  // pAllocator typed to MyCustomAllocator*
{% endhighlight %}

As I said in my previous posts, new is just another C++ function.  As such it participates in overload resolution.  This code now binds to the placement new operator and not the placement allocation overload which takes a reference.  At first I thought about using a regex search and replace to solve the issue.  However I decided this wasn't a complete solution.  There is no guarantee that my regex will catch every case and any case I miss won't crash until we actually hit the line of code.

The best case scenario here is to turn that line into a compile error.  That would guarantee that I fix every location that is a problem.  Since new participates in overload resolution you can solve this with a template.  
    
{% highlight c++ %}
template <typename T>
static inline
void* _cdecl operator new(size_t cbSize, T* allocator)
{
    allocator->ThisWillForceACompileError();
}        
{% endhighlight %}

This caused all places where a pointer type was passed to new which wasn't explicitly "void*" to turn into a compiler error.  This quickly outlined all of the places I needed to fix up and guaranteed that my fix didn't allow developers who were accustomed to using a pointer to the allocator to accidentally introduce a bug into the code base (myself included :)).


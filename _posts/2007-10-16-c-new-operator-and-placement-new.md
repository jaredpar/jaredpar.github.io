---
layout: post
---
Originally I was going to write this article to detail a particular problem I had recently with placement new in C++.  A page or two of writing later I decided it would be best to start with an introduction to the "new" operator itself and the in/outs of overloading/replacing it.  The C++ new operator really functions as a 2 step process.

  1. Allocate memory - This is accomplished by calling the in scope "new" operator 
  2. Construct object in the allocated memory - Essentially the "this" pointer is pointed to the front of the memory and the constructor is called. 

You can customize the new operator in your code by defined operator new at a particular scope.


{% highlight c++ %}
static inline
void * _cdecl operator new(size_t cbSize)
{
 ... // Return cbSize bytes
}
{% endhighlight %}

One item a lot of people don't realize is that "new" is for most purposes a normal C++ function.  Like a normal C++ function you can add parameters.  Below is a common overload you will see in code.  It is typically referred to as placement new.

{% highlight c++ %}
// Placement new
static inline
void * _cdecl operator new(
    size_t cbSize,
    void * pv)
{
    return pv;
}
{% endhighlight %}

The next question is how to pass the "pv" parameter?  When you want to pass additional parameters to "new" you can do so by opening up an argument paren block immediately after the new.  When attempting to bind the operator "new" in scope, the C++ compiler will match the first passed argument to the second argument of the defined new, second to third and so on.

{% highlight c++ %}
Student *p = new (NULL) Student();
{% endhighlight %}

This will match the second new operator I defined as NULL is compatible with void*.  This particular version of new, placement new, is valuable because it lets you customize how memory is allocated for a particular operation but still us standard C++ constructor syntax.  When you redefine operator new you are only taking care of the first step in the C++ new process; memory allocation.  The compiler will still perform step #2 on the memory returned from new.  This allows the following pattern.

{% highlight c++ %}
void *p = myAllocator.Allocate(sizeof(Student));
Student *p = new (p) Student();
{% endhighlight %}

The second line will bind to the placement new operator I defined above and will simply return the value of "p".  Student will then be constructed in this memory.

Next time I'll dive into how to make the placement new operator make a custom allocation pattern easier.


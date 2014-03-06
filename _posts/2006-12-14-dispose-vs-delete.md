---
layout: post
---
Programs allocate resources for use during execution.  The problem with resources is that they are limited and often times need to be recycled.  Languages devise constructs and patterns for developers to periodically free up resources so that their programs can continue running.

In Native C++ you typically dealt with two kinds of resources that needed recyling.

* Memory
* Operating System Resources (usually handles of one form or another)

C++ uses the "delete" operator and destructors to handle reclying both resources.  When "delete" is called on an object it will call it's destructor and then free the memory (in that order).  Operating system resources are typically freed in the destructor of a C++ object ([Resource Aquisition is Ini tialization](http://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initializati on)).  So in one fell swoop the "delete" operator handles recycling both C++ types of resources.

.Net is garbage collected and hence only has to deal with one kind of resource.

* Operating System Resources 

.Net has no "delete" call because you're not meant to be freeing memory in yourself (it's the CLR's job).  .Net objects which handle operating system resources typically free them up via the Dispose interface.  Most languages (including C# and VB) provide a "using" pattern by which you can easily hold onto a resource for a given time and guarantee it will be freed at the end of the operation.

The problem comes when people familiar with C++ "delete" semantics attempt to apply them to the .Net dispose pattern.  Dispose does **not** free managed objects memory.  The memory of the object is still available and can be accessed just fine.

This is not saying that's a good idea (in fact it's typically a bad one).  Most objects provide for very unpredictable behavior once Dispose has been called and hence you shouldn't be using them.


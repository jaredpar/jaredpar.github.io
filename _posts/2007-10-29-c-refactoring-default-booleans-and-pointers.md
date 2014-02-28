---
layout: post
---
This is another recount of an experience I had refactoring some C++ code
recently.  In some ways this is also a follow up of my previous post about why
you shouldn't use [boolean
parameters](http://blogs.msdn.com/jaredpar/archive/2007/01/23/boolean-
parameters.aspx) (especially default value ones).

I recently refactored a large set of API's in our code base to remove a common
parameter.  It was a member variable that was constantly being passed as an
argument.  For many reasons we decide that this was unacceptable and it was
better to use the member variable for instance methods and if needed define
static methods which took the parameter as a value.

After making the switch I recompiled and starting running regression suites on
the code and found that a whole set were failing.  It turns out that many of
our methods had the following pattern.

    
    
    class Student;


    


    int CalculateValue(Student *pStudent, Manager *pManager, bool cache=false);

The parameter I was removing was "pManager".  So now we have a function that
used to take 2 or 3 arguments and now takes 1 or 2 arguments.  Unfortunately,
now all of the places that used to call this function with 2 arguments will
now recompile without warning since pointers are implicitly convertible to
booleans.

No matter.  Redefined the method with the same arguments and did not specify
an implementation.  This caused compiler errors where necessary and allowed me
to fixup the calling code.

Boolean parameters are troublesome.  Defaulted value boolean parameters are
much more so.

Yes you could attribute this to the fact that I didn't fully think through a
subset of my changes and that's certainly fair.  However if we practiced good
coding standards up front, this could have been avoided.  If we had originally
done any of the following the code would be more resilient to changes.

  1. Chosen an enum instead of a boolean parameter
  2. Forced the caller to specify the boolean parameter by not providing a default


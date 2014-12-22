---
layout: post
---
Recently I had a half day adventure trying to catch a SafeIntException in code I was writing.  The particular function involved a bit of math with user controlled values.  Writing a bunch of IfFailGo's with several TryAdd style API's was getting tiresome so I decided to just use SafeInt, catch an overflow and return a failure code.

After recompiling the code I got an error because I hadn't enabled C++ exception handling in the project.  Fix to support synchronous exceptions (/Ehs), recompile.  Now I get a different error because a portion of the code base is using SEH exception handling.  No problem, changed the project to support asynchronous exception handling as well (/Eha).  And yet again another error, the compiler now said that I could not use variables with a destructor in the same method that had an SEH try block.

This put me in a bit of a corner.  The code base is littered with SEH exception handling and much of it is perfectly valid.  Luckily the number of places using both SEH and destructors was fairly limited.  What I needed was a way to unify the exception handling to allow me to use destructors in the same place as SEH exceptions.

With /Eha there is a built-in way.  You can catch all SEH exceptions using the C++ syntax "catch (...)".  However this method is limiting because you cannot access the SEH exception code and you get notified after the stack unwind occurs.  In SEH an exception filter is run before a stack unwind occurs which makes it infinitely easier to track down your bugs as you can just look down the stack trace and see the line of code that faulted.

After a bit of research I found a solution.  I'm chose to blog about it because many of the questions I needed answers for were either 1) undocumented or 2) documented to vaguely.  In the end I setup some experiment projects to confirm the behaviors I expected.

The magic function I was looking for was [_set_se_translator](http://msdn2.microsoft.com/en-us/library/5z4bw5h5\(VS.80\).aspx).  It takes a function pointer as an argument and returns the previous value.  The documentation states that when a C/SEH exception is raised this function pointer is called once per function that has a C++ try block.  It can be used to throw a C++ exception in place of a SEH exception.  So you can now translate a SEH exception into a C++ one.

What the documentation didn't explain (and I was very curious about) is how this interweaves with existing SEH __try/__except/__finally blocks.  After some experimentation I discovered that it works extremely well.  SEH exceptions occur in two phases

  1. Process the exception filters until either EXCEPTION_EXECUTE_HANDLER or EXCEPTION_CONTINUE_EXECUTION is returned
  2. If EXECEPTION_EXECUTE_HANDLER is returned the stack is unwound to the point of the exception handler block and it is then executed. 

The value passed to [_set_se_translator](http://msdn2.microsoft.com/en-us/library/5z4bw5h5\(VS.80\).aspx) participates in phase 1 of the process.  As the CRT is looking down the stack for a SEH exception filter, if it finds a C++ try block it will also process the last value passed to [_set_se_translator](http://msdn2.microsoft.com/en- us/library/5z4bw5h5\(VS.80\).aspx) and allow it to throw a C++ exception.  If an exception is thrown the stack is unwound to that point and then the exception is thrown.  This means that if you call into other code which uses traditional SEH handlers they will operate just as they did before you started using [_set_se_translator](http://msdn2.microsoft.com/en-us/library/5z4bw5h5\(VS.80\).aspx).  Most importantly __finally blocks will run and __except blocks above you in the stack still process and can handle SEH exceptions.

The next step was to write an easy to use wrapper for this functionality.  I used two classes to implement this approach.

The first class is designed to properly install a translator at a given point in the stack and ensure that it is reset to the previous value when that stack frame is popped off.
    
``` c++
extern void SehTranslatorFunction(unsigned int, struct _EXCEPTION_POINTERS*);

class SehGuard
{
public:
    SehGuard()
    {
        m_prev = _set_se_translator(SehTranslatorFunction);
    }

    ~SehGuard()
    {
        _set_se_translator(m_prev);
    }

private:
    _se_translator_function m_prev;
};
```

The second part is to actually throw an exception inside of SehTranslatorFunction.  Also to add an assert so that when an SEH exception is produced I can break at the point of failure (as opposed to in the catch block where the stack will be unwound.

    
``` c++
class SehException
{
public:
    SehException(int code) : m_code(code) { }
private:
    unsigned int m_code;
};
void SehTranslatorFunction(unsigned int code, struct _EXCEPTION_POINTERS*)
{
    MyAssertFunction(false,"Caught an SEH exception");
    throw SehException(code);
}
```

Now whenever I hit a point where I want to guard against SEH exceptions, I just put and instance of SehGuard on the stack and catch SehException instances.  No traditional SEH needed.


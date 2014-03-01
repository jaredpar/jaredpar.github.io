---
layout: post
---
Recently I got bit by void* again because of another C++ quirk I didn't think
through. I had a class which wrapped a void* which could be one of many
different structs. The structs were POD and didn't have any shared
functionality hence I didn't bother creating an inheritance hierarchy.
Unfortunately I defined the structs like so

    
    
    class C1 {


      struct S1 {


        int field1;


        float field2;


      };


      struct S2 {


        char field1;


      };


      ~C1() {


        delete m_pData;


      }


      void* m_pData; // Can be S1,S2,etc ...


    }

Unfortunately this **appeared **to work fine for quite some time. Then after
a couple of days of bug fixes I ended up with a memory leak which I quickly
tracked down to a leaked COM object. Although C1 was at fault I didn't
suspect any changes to this class because after all it was working fine for
some time and all I did was add a new field to one of the structs. If the
structs were being successfully free'd before a new field shouldn't change
anything.

The field I added was of type CComPtr<T> which exposed a greater problem in my
code. Even though I properly delete the pointer in C1::~C1() I wasn't running
the destructor on the pointed at data and instead I was just freeing the
memory. Until I added a field which had a non-trivial destructor this wasn't
a problem (still a bug though).

Why did this happen' By deleting a void* and expecting a destructor to run
what I'm really doing is asking C++ to behave polymorphicly. C++ as a rule
won't behave this way unless it is specifically asked to with inheritance and
virtual.'? In the case of void*, it just won't. The fix is to actually
implement an inheritance hierarchy which supports polymorphism.

It's just another rule that I need to remember when coding C++.

> Deleting void* is dangerous, period.

Unfortunately C++ has too many of these rules and not enough enforcement.


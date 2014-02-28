---
layout: post
---
This is a more amusing than functional debate I enter into from time to time.
On a line where you declare a pointer type in C++, where should the * go?

  1. Next to the type (i.e. Type* p1;) 
  2. Next to the variable name  (i.e. Type *p1;) 
  3. Who cares

For the moment lets ignore #3 (after all they don't care).  I'm a firm
believer in #1.  After all * is a part of the type of the variable, not the
name and therefore should be closer to the type.

#2 believers disagree with this notion.  They believe the * is a part of the
individual variable's type and not the actual type.  This is technically
correct and can be demonstrated with the following code

    
    
      Type* p1, p2;


    

The type of p2 is of course Type and not Type*. Therefore they argue, #2 is
the superior way

This is true but I'm also a firm believer in don't declare multiple variables
in a single declaration statement while coding in C++ unless the type has a
user defined constructor.  Namely to avoid situations just like this.


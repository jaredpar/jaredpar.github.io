---
layout: post
---
A recent check in of mine raised a few eye brows during reviews.  I checked in a few macros which ended with/contained a "do{}while(0)" and people were curious as to why.

In my experience there are two main uses for it.

  1. Insert an empty statement with no runtime penalty 
  2. Group a set of statements into a single statement followable by a semi-colon
    1. do { Func1(); Func2() } while(0) 

Macros are mutating little constructs which jump back and forth depending on the compile time options.  Many macros compile to different expressions based on the options and in some cases they compile to nothing.  This is where #1 really comes in hand.  Imagine you have the following code.  
    
``` c
if(someCondition)
MY_MACRO();
```

Compiling MY_MACRO to nothing will cause at the least a compile time warning since you will have essentially if(someCondition);. Instead you can use the do{}while(0) trick.

``` c
#if CONST_1
#define MY_MACRO() Func1()
#else
#define MY_MACRO() do{}while(0)
```

Another us is for stylistic reasons.  Some camps don't believe a ; should be used as a empty statement and use do{}while(0) instead.  I tend to agree.  Mainly because one of my early C professors had the same belief.  The habit stuck around.  

Update: Changed incorrect use of word expression -> single statement


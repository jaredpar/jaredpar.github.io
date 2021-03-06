---
layout: post
---
Using [PreFast](http://research.microsoft.com/displayArticle.aspx?id=634) internally we recently came across a class of bugs.  In several places we were using uninitialized structures as local variables.  The error came about because the types in question had no default constructor.  For instance take the following structure

    
``` c++
struct s1
{
    int m1;
    int m2;
};
```

This structure does not have a default constructor and hence the values for a local are not guaranteed to be any value.  At first I thought this would be a simple fix.  All I needed to do was add a default constructor that initializes the members to known values.  At first I wondered why the original type author hadn't bothered to do this.  
    
``` c++
s1() : m1(0),m2(0) { }
```

Now this looks well and good, I re-compile and get a whole lot of errors.  It turns out that we have several unions defined for s1.

``` c++
union 
{
    s1 u1;
    int u2;
};
```

It's not legal for a union member to have a non-trivial default constructor.  The next solution is to use a C++ hack to initialize the variables on the stack.

``` c++
s1 x = {0};
```

I consider this a hack for a few reasons

1. It only works if you need everything to be initialized to 0
2. It spreads out the logic for your type.  Instead of being localized to the actual type definition code it's now spread out to the type use. 
3. It's hard to maintain because if you ever add another member that requires different initialization you must update every single use of the type.  Worst of all you can add said member and won't get a single error or warning about it. 

In the end for types where 0 didn't make sense we ended up using a factory pattern to initialize the variables.

All I wanted was a constructor.


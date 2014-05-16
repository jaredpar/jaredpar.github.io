---
layout: post
title: Return Values vs. Exceptions: They Both Suck 
---

Outside of the overall architecture of the program errors are simply the most interesting thing about the code.  Programs can fail in the most s

If everything went right in programs coding would be rather dull.  Lucky for us customers have a variety of machines, setups, drivers, etc ... that make programming interesting.  This is why correct error handling is essential to correct programs.  

Errors are most likely to pop up on customer machines  


Whenever the topic of C++ best practices comes up for a code base it will inevitably devolve into a discussion about errors vs. exceptions.  Many of these discussions turn into 

They are both very crappy ways of handling errors in an application.  Forget perf, best practices, etc ...  When I think of error handling I want a feature which will 

1. Make the error handling paths visible to even the casual reader of the code
2. Prevent errors from being silently ignored
3. Distinguish between functions that can fail and functions that can't 



 it will inevitably end up discussing the topic of error handling.  In particular whether the code base should use exceptions or 

These arguments seem to be starting from the wrong place.  

My opinion on this is pretty simple: they both suck.  Ideally error handling in programming should have at least the following two properties

1. The code flow of errors should be visible to the casual observer 
2. Error scenarios cannot be silently ignored 

```csharp
class C {
  int field;
}
```

blah
    
{% highlight csharp %}
class C { } 
{% endhighlight %} 
    




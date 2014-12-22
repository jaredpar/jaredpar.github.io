---
layout: post
---
Paul Vick [posted](http://www.panopticoncentral.net/archive/2008/05/08/23317.aspx) a recent entry exploring the necessity, or lack there of, for having reserved words in a programming language.  It's an interesting mental exercise to go through.  At the end you'll realize that many reserved keywords aren't needed from the perspective of the compiler.  This is part of the reason C# and VB are defaulting more to contextual keywords in recent releases.  What the blog post didn't really talk about though was the programmer.  From the programmer's perspective there is one great reason for reserved words.

Sanity.

Going through legacy code is hard enough already.  Reserved words at least allow you to mentally structure the code you are looking at.  If there was open season on the use of keywords you know someone will take advantage and flat out abuse the system.  Can you imagine digging through some legacy C++ and seeing the following [^1]

    
``` c++
class int : public new { public: new private; }
new void() {
  int int = new new;
  int.private = int;
  return int;
}
```

Reading that makes my head hurt.

Having reserved words is a language adds a modicum of structure.  Language structure allows developers to more quickly grasp the meaning and intent of a piece of code.  Can you imagine trying to grasp a more complex example?  Now imagine the programmer had several thousand lines of undocumented code with this pattern.  Not fun.

[^1] Yes I realize that making new/int non-reserved words may not be possible in C++.  But this is just a hypothetical example.


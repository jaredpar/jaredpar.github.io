---
layout: post
---
The Expression Evaluator is a VSIP component that allows Visual Studio
Languages to plug in a Debugger.  It's what controls the information inside
the locals,watch,auto, stack frame and immediate windows during a debugging
session.  Both VB and C# use this API to plug in their debugger displays to
Visual Studio.

Here is a link the MSDN page overviewing this component.

<http://msdn2.microsoft.com/en-us/library/bb161694(VS.80).aspx>

The Expression Evaluator (EE) layer is very flexible and gives the library
author a lot of room to create custom displays, evaluators and so forth.  The
only real downside to the layer is the documentation.  Namely there isn't much
around :(

I use this layer as part of my daily dev life while working on the Visual
Basic Debugger layer.  After encouragement from a few customers and internal
Microsoft employees I decided to start blogging about this VSIP layer.  Mainly
I want to help people who are writing Expression Evaluators out by giving
tutorials on getting the fun things working (type visualizers, proxies,
display attributes) and also warn about the various pitfalls involved with the
API.

If you have any suggestions for entries or questions about the Expression
Evaluator or Symbol Provider layer please post them in the comments or email
me through the link.  I'd really like this part of my blog to be customer
driven given that there are a limited number of users who want to plug into
this layer.

I'll be tagging these entries wit the EESdk flag.


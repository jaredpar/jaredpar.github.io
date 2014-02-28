---
layout: post
---
This falls into the "learn something new everyday but not necessarily entirely
useful bucket".  An app I spend a bit of time on leverages the CodeDom heavily
to spit out managed code.  While running through some test cases the other day
I noticed that it was prefixing many identifier names with the @ symbol when
the generated code was C#.

At first I assumed this was a bug in my code but I noticed that the generated
code compiled just fine.  A bit of digging through the C# spec turned up the
purpose of the @ character. This allows you to use C# keywords as identifiers.
For instance you can have "class @class".

<http://msdn2.microsoft.com/en-us/library/aa664670(VS.71).aspx>

VB has the same type of feature but they require the name to be wrapped in [].

This still didn't answer the question of why my code generated with this
character. It turns out this is a feature of the C# CodeDom.  When outputting
an identifier, the C# CodeDom will prefix the identifier with @ if one of the
following conditions are true.

  1. The identifier is a keyword
  2. The identifier is prefixed with two underscores.

It turns out the second rule exists to allow flexibility in the C# compiler
implementation.  All identifiers that are prefixed with two underscores are
inherently reserved for the implementation to provide such actions as extended
keywords (reference at bottom of above link).


---
layout: post
---
A feature which seems to be getting more requests recently is support for
seeing the return value of a function in the debugger without the need to
assign it into a temporary.  C++'s had this feature for some time but it's
been lacking in managed debugging scenarios.  [James
Manning](http://blog.sublogic.com/) recently dedicated a couple of [blog
posts](http://blog.sublogic.com/2010/11/22/visual-studio-debugger-request-
return-local-variable/) to the subject and
[noted](http://blog.sublogic.com/2010/12/11/showing-c-method-return-in-
debugger-vb-net-can-do-it/) that the feature appears to already partially
exist for VB.Net

> "With VB.NET, the function name shows up as an entry in 'Locals' and the
debugger shows us the value it's returning!  The C# debugger has no such
support, though - at the same 'end of method' breakpoint, only the parameter
passed in is shown.   So, clearly the CLR has enough support for the VB.NET
debugger to support this feature, which would seem to be a pretty strong
argument that the C# debugger certainly **could** implement this feature."

Indeed C# could implement this feature but it's not a CLR debugging feature
that VB.Net is relying on but is rather an issue of VB6 legacy support.  The
VB6 language didn't have a return statement.  Instead values were returned by
assigning the value to be returned to the name of the function.  For example

    
    
        Function IsEven(ByVal i As Integer)


            If i Mod 2 = 0 Then IsEven = True Else IsEven = False End If End Function 

While VB.Net added a Return statement it still supports this legacy syntax
(and it allows the two to be mixed within a single function).  The compiler
models this by having a local of the same name of the function which is used
to store the return value.  Returns from the function are rewritten as
assignments to this local and then a return of the same local.  The debugger
understands this hidden local and displays it during the debugging session.
This gives VB.Net the appearance of supporting Return value display when in
reality it's just a positive side effect of legacy support.

Quick Note:  In my experience when [users
ask](http://stackoverflow.com/questions/591086/vs-get-returned-value-
in-c-code) for return value support in the debugger they typically want to see
both

  1. The return value of the current function they're stepping through
  2. The return value of functions which are stepped over (more heavily requested)

VB.Net supports only the first one (via the described method) and C# supports
neither.

I do agree it would be really nice if both languages supported #2 (it's an
incredibly useful feature in C++).  It is possible to do without CLR support
but it involves the compiler generating a temporary for every function /
property evaluated in a statement and lots of copying values around.  This can
have a non-trivial impact on program performance even when not debugging and
hence I think is unlikely to be done.  If #2 does come around it will likely
be through the CLR debugger APIs providing access to the return values much in
the way it provides access to the [current
exception](http://msdn.microsoft.com/en-us/library/ms230540\(pt-
br,VS.90\).aspx).

**Update **

Starting with Visual Studio 2013 there will be return value debugging support
for all managed languages in a uniform manner.  It will be exposed in the same
way that C++ exposes function return values.  More details are available here

<http://blogs.msdn.com/b/somasegar/archive/2013/06/26/visual-
studio-2013-preview.aspx>

****


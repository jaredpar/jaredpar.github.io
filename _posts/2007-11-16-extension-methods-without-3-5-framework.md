---
layout: post
---
For a time I've been avoiding extension methods.  Not because I'm opposed to
using them but because of the 3.5 Framework.

A lot of the tools I own are designed to be very light weight tools that only
require the user to have 2.0 installed on their machine.  I find that the
easier that tools are to install, the more likely people are to use them.

Extension methods require the ExtensionAttribute be available.  Since the
attribute is declared in a 3.5 Framework assembly it's not possible to use
extension methods without the 3.5 framework.  At least, that's what I thought
up until I read an recent MSDN article.

You can simply define the ExtensionAttribute in your assembly and extension
methods will start working.  No references to the 3.5 framework required.
It's a lightweight solution that adds the full power of extension methods to
your program.

    
    
    Namespace System.Runtime.CompilerServices


        Class ExtensionAttribute


            Inherits Attribute


        End Class


    End Namespace


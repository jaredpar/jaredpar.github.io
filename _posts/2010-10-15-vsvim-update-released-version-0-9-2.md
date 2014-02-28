---
layout: post
---
I just released an update to VsVim for Visual Studio 2010.  This is available
on the extension manager in Visual Studio or can be downloaded directly at the
following link.

Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-
8fe1-0e90e3f79329>

GitHub: <http://github.com/jaredpar/VsVim>

This is fairly major release from the last announced (0.8.2) which includes
the following changes

  * Essentially a rewrite of Visual Mode
  * New motions f, F, t, T, e, [, [[, ], ]], (, ), {, } 
  * Visual Studio integration improvements
  * Memory leak fixes
  * Fixes for international keyboard issues 
  * And of course many bug fixes 

I do want to take a second and thank two VsVim users,
[pedrosal](http://github.com/pedrosal) and
[tuncbah](http://github.com/tuncbah), for reporting several international
keyboard issues, helping me to understand the problem and testing out my
fixes.  They were particularly nasty issues that caused me a bit of trouble.

**Future Plans**

We're quickly approaching a 1.0.0 release.  My initial goal for 1.0.0 was to
have a largely functional Vim emulation layer on top of Visual Studio.  With
the following features currently in progress I think VsVim will be well within
that goal

  * Vim style regex support - right now all regex's are done with vanilla BCL regex's 
  * Clipboard support 
  * Improvements to the . operator 

This work is well under way and I hope to complete it within the next month or
so.  Releasing 1.0 will be a huge milestone for us but will by no means be the
end of the work.

**The usual caveats and expectations**

This extension is being released by me, not by Microsoft.  As such the support
level for this extension is equivalent to the amount of free time I have to
put into it.

Source for this release is available on the [GitHub project
site](http://github.com/jaredpar/VsVim).  It and the associated binaries are
released under the [MS-PL](http://msdn.microsoft.com/en-
us/library/cc707818.aspx).


---
layout: post
---
I just released an update to VsVim for Visual Studio 2010. This is available
on the extension manager in Visual Studio or can be downloaded directly at the
following link.

Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-
8fe1-0e90e3f79329>

GitHub: <http://github.com/jaredpar/VsVim>

**New Features**

I forgot to add an entry when 0.8.0 was released so this is the main set
changes for both 0.8.0 and 0.8.1.

  * Motions: G, gg, H, M, L, f, t, F, T 
  * Options: startofline, virtualedit, visualbell, hlsearh, ignorecase, smartcase 
  * Visual Mode ' put, <, >, ~, all motions from normal mode 
  * Normal Mode ' D, ~, N, Ctrl-F, Ctrl-B, 
  * Command Mode ' qa 

**Notable Bug Fixes**

  * VsVim will now look for a .vsvimrc file before .vimrc. VsVim still does not support the full set of commands and certain combinations in users .vimrc caused issues.
  * Closing a file while in Insert Mode will no longer cause an exception 
  * Users can now map F1 properly in key remappings. Useful in laptops where F1 is in the place of Escape 

**Future Plans**

I will likely be releasing a 0.8.2 version in very early June when I return
from vacation to clean up a few items that just didn't make it into 0.8.1.

The current set of planned features for 0.9.0 can be seen
[here.](http://github.com/jaredpar/VsVim/issues/labels/v0.9)?? Mainly this is
filling out the remaining gaps users have reported. I've heard a few requests
now for R# support in VsVim and that will be coming. I do not know yet if
that will go into 0.9.0 or a later release. Will likely depend on how much
feedback I get on this.

**Special Thanks**

I wanted to take a second and thank all of my users who took the time to file
issues and work with me to get a solid repro so I could fix the bug. VsVim is
currently a very community driven product and I would like to see it continue
to be.

Additionally thanks to JasonMal a coworker of mine who took the F# plunge and
started helping me fix issues. The help is most appreciated.

**The usual caveats and expectations**

This extension is being released by me, not by Microsoft. As such the support
level for this extension is equivalent to the amount of free time I have to
put into it.

Source for this release is available on the [GitHub project
site](http://github.com/jaredpar/VsVim). It and the associated binaries are
released under the [MS-PL](http://msdn.microsoft.com/en-
us/library/cc707818.aspx).


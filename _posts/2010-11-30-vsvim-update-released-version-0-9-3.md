---
layout: post
---
I just released an update to VsVim for Visual Studio 2010.?? This is available
on the extension manager in Visual Studio or can be downloaded directly at the
following link.

Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-
8fe1-0e90e3f79329>

GitHub: <http://github.com/jaredpar/VsVim>

This update includes the following

  * Full support for :substitute including the confirm option 
  * Many bug fixes for the ???.??? (repeat) command 
  * Vim style regular expression support.?? Previous releases used BCL regexes 
  * Support for the + (clipboard) register 
  * And of course many bug fixes 

**Future Plans**

The original plan for VsVim was to focus on getting a highly functional Vim
emulator as the 1.0 release and then moving onto items like Resharper
integration for 1.1.?? At our current pace this would put VsVim 1.0 out the
door in just a few more weeks.?? But after receiving a lot of feedback from
users it???s become clear that integration with Resharper is more important than
rounding out the last few major Vim items.?? Hence we???ve decided to shift the
focus of the next few releases to the following

  * 0.9.4 ??? Resharper support. 
  * 0.9.5 ??? Finish remaining core Vim features (macros mainly at this point) 
  * 1.0 ??? Mostly bug fixes on top of 0.9.5 

We were really looking forward to putting the 1.0 stamp on VsVim but are
equally as excited by the proposition of getting Resharper (and likely similar
products like CodeRush) working.?? We hope to have a Beta release of the
support by early next week for users to bash on.?? When the builds are
available I???ll announce them on [twitter](http://twitter.com/jaredpar) and
upload them to the github site.

**The usual caveats and expectations**

This extension is being released by me, not by Microsoft.?? As such the support
level for this extension is equivalent to the amount of free time I have to
put into it.

Source for this release is available on the [GitHub project
site](http://github.com/jaredpar/VsVim).?? It and the associated binaries are
released under the [MS-PL](http://msdn.microsoft.com/en-
us/library/cc707818.aspx).


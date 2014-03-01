---
layout: post
---
I just released an update to VsVim for Visual Studio 2010. This is available
on the extension manager in Visual Studio or can be downloaded directly at the
following link.

Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-
8fe1-0e90e3f79329>

GitHub: <http://github.com/jaredpar/VsVim>

This update includes the following

  * Lots of undo / redo issues
  * Lots of caret positioning issues
  * Support for tabs 
  * And of course many other bug fixes

I do want to take a second and again thank [Martin
Lemburg](https://github.com/MartinLemburg) for the many detailed issues filed
during the 0.9.4 release. It really helps to have such great feedback to work
against.

Note: The latest release is 0.9.5.1. I released a patched version of 0.9.5 to
deal with bad behavior in the '%' motion which was breaking a lot of users.

**Future Plans**

I'm aiming for 0.9.6 to be a quick release cycle. The main focus of this
release is getting macros and visual block operators working. I already have
macro support working in the beta tree. I want to spend a few weeks working
out the kinks and getting through other bug fixes and then I'll release 0.9.6.

Macros represent the last major feature for the 1.0.0 release. So after 0.9.6
there will maybe be 1 more bug fix release before 1.0.0!

**The usual caveats and expectations**

This extension is being released by me, not by Microsoft. As such the support
level for this extension is equivalent to the amount of free time I have to
put into it.

Source for this release is available on the [GitHub project
site](http://github.com/jaredpar/VsVim). It and the associated binaries are
released under the[MS-PL](http://msdn.microsoft.com/en-
us/library/cc707818.aspx).


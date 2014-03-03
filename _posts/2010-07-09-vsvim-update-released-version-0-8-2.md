---
layout: post
---
I just released an update to VsVim for Visual Studio 2010. This is available on the extension manager in Visual Studio or can be downloaded directly at the following link.

Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329>

GitHub: <http://github.com/jaredpar/VsVim>

This is a bug fix release and contains no large features.

**Notable Bug Fixes**

  * Both normal mode append commands, 'a' and 'A', now correctly position the cursor after the last character of the line in all cases.
  * Several issues around the display of the : in command mode 
  * Motions e/E now correctly move past the end of the word when used as a movement
  * The dw edit lead to exceptions when deleting some times of leading whitespace 
  * Tooltips no longer interfere with normal mode commands
  * Several subtle motion issues

**Future Plans**

We are primarily working on 0.9.0 features at this point which can be seen [here](http://github.com/jaredpar/VsVim/issues/labels/v0.9). This release is continuing to fill in the gaps users have reported. Depending on how long 0.9.0 takes there may be a 0.8.3 release but right now it looks like 0.9.0 will be the next version.

**The usual caveats and expectations**

This extension is being released by me, not by Microsoft. As such the support level for this extension is equivalent to the amount of free time I have to put into it.

Source for this release is available on the [GitHub project site](http://github.com/jaredpar/VsVim). It and the associated binaries are released under the [MS-PL](http://msdn.microsoft.com/en-us/library/cc707818.aspx).


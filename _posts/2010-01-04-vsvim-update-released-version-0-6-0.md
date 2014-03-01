---
layout: post
---
I just released an update to VsVim for Visual Studio 2010 Beta2. This should
be available shortly from the extension manager in Visual Studio or it can be
downloaded directly at the following link

Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-
8fe1-0e90e3f79329>

**New Features**

  * Normal Mode Commands: Y,Delete, Arrow Keys, gP, gp, z<CR>,zt, z., zz, z-, zb
  * Command Mode Commands: d[elete], <,>, j[oin], y[ank], p[ut], 
  * Insert Mode: Fixed Intellisense window dismissal issue (see below)

**Notable Bug Fixes**

  * In previous versions intellisense didn't play well with insert mode. In particular attempting to dismiss intellisense with the Escape key would exit insert mode but leave intellisense showing. This release fixes the behavior to instead dismiss intellisense and leave you in Insert Mode
  * Normal Mode O now enters insert mode upon completion
  * Count was not being applied to certain edit commands (x) in Normal Mode
  * Normal Mode 'dw' was deleting the line break if the word was at the end of the line 

**Source Code**

Source for this release is available at the following location. It is
released under the [MS-PL](http://msdn.microsoft.com/en-
us/library/cc707818.aspx).

<http://cid-
dc25b20f65f628f8.skydrive.live.com/self.aspx/Public/VsVim/VsVim-0.6.0.zip>

**Future Plans**

The next planned major update is version 0.7.0. The two main features of this
release will be the addition of Visual Mode and the :substitute command.
Additionally I plan to flesh out a lot of the areas in normal, command and
visual mode.

**The usual caveats and expectations**

This extension is being released by me, not by Microsoft. As such the support
level for this extension is equivalent to the amount of free time I have to
put into it.


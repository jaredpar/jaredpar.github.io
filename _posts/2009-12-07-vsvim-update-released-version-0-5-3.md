---
layout: post
---
I just released an update to VsVim for Visual Studio 2010 Beta2.?? This should
be available shortly from the extension manager in Visual Studio or it can be
downloaded directly at the following link

Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-
8fe1-0e90e3f79329>

**Changes**

  * Normal Mode Block Cursor

This removes the red cursor in favor of a Vim block style cursor for normal
mode. This is implemented as a simple adornment in the editor and in the end
required much less work than I anticipated (also allowed the removal of a lot
of hacky code).?? Thanks a lot to [Noah](http://blogs.msdn.com/noahric/) for
helping me out here.

  * Basic range support in command mode.

Currently limited to line number ranges, % and . (current line)

  * Command Mode Infrastructure Changes

This infrastructure change allowed my to correctly implement the few command
mode commands I previously supported and laid the ground work for quick
support of new commands

  * New Normal Mode Commands: gJ

This release is small on features and ordinarily wouldn???t qualify for an
update.?? But the cursor change was so pleasant for myself that I decided to
release a quick update just for that.

**What???s Next?**

  * Add command mode support for all normal mode commands that have a command mode equivalent
  * Resolve normal mode edits around a selection.?? Currently selection is ignored and it produces unexpected behavior.??
  * More normal mode commands: In particular, Delete, gt, gT, global mark navigation 
  * Lifetime issues around buffers and Vim???s internal object model
  * Navigation in a buffer which contains multiple font sizes

**The usual caveats and expectations**

This extension is being released by me, not by Microsoft.?? As such the support
level for this extension is equivalent to the amount of free time I have to
put into it.


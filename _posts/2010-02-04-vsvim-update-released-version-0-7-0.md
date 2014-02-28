---
layout: post
---
I just released an update to VsVim for Visual Studio 2010 Beta2.  This should
be available shortly from the extension manager in Visual Studio or it can be
downloaded directly at the following link

Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-
8fe1-0e90e3f79329>

**New Features**

  * Visual Mode Support 
    * Character, Line and Block Mode 
    * All movement commands supported 
    * Basic insert-delete operations added 
  * Command Mode Commands - :substitute, :redo, 
  * Support for mark navigation to global marks 
  * Implemented almost all delete-insert operations in relevant modes 
  * Normal Mode Commands: CTRL-R, 
  * Expanded range parsing 

**Notable Bug Fixes**

  * Issues with disabling conflicting key bindings on startup 
  * Issues with not properly intercepting standard VS commands and routing them to Vim 
  * Timing issue on startup that would cause certain components to not get created 

**Source Code**

Source for this release is available at the following location.  It is
released under the [MS-PL](http://msdn.microsoft.com/en-
us/library/cc707818.aspx).

<http://cid-
dc25b20f65f628f8.skydrive.live.com/self.aspx/Public/VsVim/VsVim-0.7.0.zip>

**Future Plans**

The next planned major update is version 0.8.0.  It will consist of the
following updates

  * Expanded set of commands supported in all modes 
  * The . operator in normal mode 
  * Ability for users to change settings.  Settings supported is baked into VsVim I just haven???t exposed it via command mode or any UI 
  * Better UI in general.  Right now I use MessageBox.Show for any UI I need to display other than status bar updates.  I would like to expand that to include a more configurable UI 

I also expect to release a 0.7.1 version once the Visual Studio RC goes
public.  As part of releasing RC, all Beta2 extensions will be unpublished in
the gallery and I???ll need to release an RC compatible version.  At that time I
will provide a link to the Beta2 binaries for those not upgrading to the RC.

**The usual caveats and expectations**

This extension is being released by me, not by Microsoft.  As such the support
level for this extension is equivalent to the amount of free time I have to
put into it.


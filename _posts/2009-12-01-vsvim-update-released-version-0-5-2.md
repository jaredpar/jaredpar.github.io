---
layout: post
---
I just released an update to VsVim for Visual Studio 2010 Beta2. This should be available shortly from the extension manager in Visual Studio or it can be downloaded directly at the following link 
Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329>

**Changes**

  * Removal of conflicting key bindings

On startup VsVim will now look for any key bindings which conflict with implemented Vim commands. It will then provide a message box allowing you to remove the key bindings for this session of Visual Studio. Right now this is an all or nothing removal, future versions may make this a more granular process

  * Normal Mode no longer intercepts all keystrokes (such as Cut and Paste)

This bug in the previous release was a result of the command routing changes that occured between Beta1 and Beta2. I believe I know have them all worked out and VsVim should only be intercepting commands it intends to process 

  * New Normal Mode Commands
    * Mark setting: m[a-zA-Z]
    * Mark Jump: `[a-z], '[a-z] 
      * This is currently limited to local marks 
    * Page Up, Page Down: CTRL-U,CTRL-D
    * Join: j

**What's Next?**

The biggest area I want to focus on for the next release is Command mode and rounding, more normal mode behavior (especially mark support) and basic range support.

At a minimum I want to expand all of the normal mode commands I have implemented to have their corresponding command mode version implemented.  Join, mark, etc '?? This shouldn't be a big work item. Command mode is just something I've been neglecting up to this point in favor of infrastructure.  

The other big item I want to work on is ranges. Many command mode commands operate on ranges and it's something I've yet to implement at a core level.  The basic mark support I added in this release starts the process but I have a ways to go.

Also, any suggestions users have are very welcome.

**The usual caveats and expectations**

This extension is being released by me, not by Microsoft. As such the support level for this extension is equivalent to the amount of free time I have to put into it.


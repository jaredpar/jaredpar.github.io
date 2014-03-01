---
layout: post
---
This is essentially the same release as the
[original](http://blogs.msdn.com/jaredpar/archive/2009/09/08/vim-emulator-
editor-extension-released.aspx) but updated for some changes that occurred in
the APIs between Beta1 and Beta2.

Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-
8fe1-0e90e3f79329>

The biggest change came in the way in which Visual Studio routes commands.
Vim, as you can imagine, needs to participate in command routing and these
changes took awhile to sort out. I believe I've sorted out the issues but
please send me a mail / comment if you find any bugs.

**Caveats and Expectations**

This extension is being released by me, not by Microsoft. As such the support
level for this extension is equivalent to the amount of free time I have to
put into it.

**What's next?**

Right now the Visual Studio command system is the biggest inhibitor to
implementing new features. Each command in Visual Studio is bound to a
specific key stroke and often times this conflicts with key strokes my Vim
emulator needs to process.

It's easy to implement these commands in the core Vim engine. However the
actual key strokes get intercepted by Visual Studio and are not processed.

My next feature will be essentially removing these commands so that they can
make it to the Vim layer. It will require a bit of a UI since I'll be
essentially changing key bindings but hopefully I can get something basic out
the door so that I can start focusing on real features again.


---
layout: post
---
I just released version 0.5.0 of VsVim: a vim emulation editor extension for
Visual Studio 2010 Beta1 written in F#.  This is a hobby project I've been
working on for awhile now.  I expect to continue updating this release as time
goes on as I use it on a daily basis and I'm interested in getting back
feedback from users on it.  

Link: <http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-
8fe1-0e90e3f79329>

Here's a quick break down on the state of this project

**Caveats and Expectations**

This extension is being released by me, not by Microsoft.  As such the support
level for this extension is equivalent to the amount of free time I have to
put into it.

**Quality Level**

I would classify this as a Beta style release.  I use this extension every day
and I have a very large test bed to verify functionality.  There are still
several known bugs (detailed below) and little quirks I'm working on.  But
they are mostly minor issues

**What's Implemented**

At this point the engine has an Insert, Normal and Command mode.

  * Insert Mode

    * Basic insertion layer which allows for typing.  No special insert mode commands are implemented 

  * Normal Mode.

    * Movement Commands: h,j,k,l,w,b,$,^,n,*,# 
    * Edit Commands: x,X,d,p,P,A,u,<,>,o 
    * Incremental Search 
  * Command Mode

    * :e

    * Jump to line

    * Beginning / end of line

**Deviations **

The biggest deviation I made from a traditional VIM engine is that I am using
.Net regular expressions instead of VIM style regular expressions.  This
allowed me to focus on getting a lot of features written vs. spending time
building a regular expression engine.  Getting this working will be a focus of
a later release.

Another issue is the cursor.  As flexible as the new editor is, one part that
is very tricky is changing the appearance of the cursor.  So making a block
style cursor for normal mode was not done for this release.  Instead I simply
color the cursor red for normal mode and black for insert mode.  This will be
fixed in a later release.

**Bugs**

Below is the list of known issues for the extension.  I've noted all bugs for
which I cannot get a steady repro.  If you can find one I would appreciate you
emailing the steps to me.

  * Cursor appearance in normal mode is not a block cursor but instead a red cursor 

  * Need Repro: Using 'o' in normal mode can cause the line ending to switch from \r\n to \r or \n. 
  * Both '#' and '*' match partial words instead of full words

  * Register list is limited to standard a-z alphabet 

**What's next?**

Thus far I've been working on features which don't conflict with existing
Visual Studio key bindings.  The next big release will be focusing on the
infrastructure needed to integrate these commands smoothly into the core Vim
engine and Visual Studio itself.  This will allow me to expand the number of
implemented features a great deal.

**Where's the source?**

Should be released soon.  Right now I'm working out where I should host this
project long term.  Preferably a place where users can file bugs and leave
feedback.

  




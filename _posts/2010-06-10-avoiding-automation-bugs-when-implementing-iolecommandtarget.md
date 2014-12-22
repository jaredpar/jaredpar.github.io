---
layout: post
title: Avoiding Automation Bugs When Implementing IOleCommandTarget
tags: [vsix]
---
Shortly after Visual Studio 2010 shipped I wanted to experiment with the new VSIX format for traditional Package extensions. I fired up my copy of Visual Studio, ran through the new package project wizard. But instead of a nice shiny new project I was greeted with a project load error dialog. After a bit of investigation I found the generated project file was corrupt. The majority of the template code was not replaced.

A bit disturbed that we shipped such a bug I immediately fired an email off to the appropriate team and inquired about the situation. I got back a very quick psychic debugging response.  

> Do you have any extensions installed on the machine?

After a quick check I verified the only extension on my machine was my very own [VsVim](http://visualstudiogallery.msdn.microsoft.com/en-us/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329) project. I naturally assumed this couldn't be any fault of VsVim because it doesn't participate?? in project creation and no other project type was affected. Imagine my surprise then that after uninstalling VsVim everything started working as expected. After a few more verification runs, and a bit of self shame, I realized it indeed was my problem and got out the debugger.

It turns out the package wizard does project file substitution a bit differently than the project project templates. It uses the [DTE object model](http://msdn.microsoft.com/en-us/library/envdte\(VS.80\).aspx) to do the replacements. DTE is different than the other VSIP interfaces in that it is intended to participate in automation (aka Macros).'? Operations tend to avoid manipulating the buffer directly but instead raise a command which is later handled by another component in the editor. Using the command system allows DTE to participate in automation.

For example operations like [TextSelection.Delete](http://msdn.microsoft.com/en-us/library/envdte.textselection.delete\(VS.80\).aspx) don't directly delete text from the buffer. Instead it just raises the command which represents the user hitting the delete key which is eventually handled by the editor and deletes the selection. These commands are processed through the [IOleCommandTarget](http://msdn.microsoft.com/en-us/library/ms683797\(VS.85\).aspx) chain for a given IVsTextView.

Once I found out this it became immediately apparent what was happening. The package wizard is effectively sending keystrokes to a buffer with the intend of performing edits. VsVim uses [IOleCommandTarget](http://msdn.microsoft.com/en-us/library/ms683797\(VS.85\).aspx) to intercept key strokes and was happily treating them as Vim commands.

The implications are even further reaching than just the package wizard.  Macros primarily operate on the DTE object model hence I was also breaking them (very badly indeed).

Luckily there is a very simply fix to the problem. Visual Studio provides a nice helper method which allows you to determine if you are currently in the middle of automation. Adding a [simple check](http://github.com/jaredpar/VsVim/commit/df0b6e6c1c95ff53acc14cbd5ad3cf5ccca05cd0) for this at my IOleCommandTarget entry points cleared up the issues nicely.

    
``` csharp
if (VsShellUtilities.IsInAutomationFunction(_serviceProvider))
{
    return false;
}
```

In general any component in the IOleCommandTarget chain should be making the same check on both QueryStatus and Exec. Unless your component is specifically designed for macros and automations handling a command during automation will lead to hard to track down issues.


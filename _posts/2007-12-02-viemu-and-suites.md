---
layout: post
---
[ViEmu](http://www.viemu.com/) is a Visual Studio Package which adds Vim
keybinding support into Visual Studio.?? For former VI users this is huge
benefit as I can use all of my cryptic key combinations inside of Visual
Studio.

For those unfamiliar, Vi is one of the original editors for the Unix operating
systems.?? Vim (VI iMproved) is a set of improvements on the original Vi
editor.?? At it's core Vi/Vim is a modal editor which means that it has
multiple modes of input.?? Mainly there are

  1. Command - allows you to enter commands to the editor
  2. Edit -modifying the text

Getting started with Vi/Vim is quite a challenge because the learning curve is
incredibly steep.?? Once you get it down though you can accomplish a whole lot
more with just a few key strokes.?? ViEmu brings this power into Visual Studio.

The only downside is that ViEmu dramatically alters the way keystrokes affect
the environment.?? This is a really interferes when I need to run code suites
on my machine as it will cause any that use keystrokes to fail.

Again, PowerShell is the answer.?? I just disable ViEmu while suites are
running on my machine and quickly re-enable them afterwards.

function Enable-ViEmu()  
{  
?????? sp "hkcu:\software\microsoft\VisualStudio\9.0\ViEmu" "Enable" 1  
?????? sp "hkcu:\software\microsoft\VisualStudio\9.0\ViEmu" "AllowKbdClashes" 0  
}

function Disable-ViEmu()  
{  
?????? sp "hkcu:\software\microsoft\VisualStudio\9.0\ViEmu" "Enable" 0  
?????? sp "hkcu:\software\microsoft\VisualStudio\9.0\ViEmu" "AllowKbdClashes" 1  
}

ViEmu provides this UI but it's a mode switch.?? I tend to run my suites from
the command line and I find opening the UI and disabling takes too much time
and is a distraction.?? Running a quick disable-viemu takes virtually no time
and fits right into the command line.


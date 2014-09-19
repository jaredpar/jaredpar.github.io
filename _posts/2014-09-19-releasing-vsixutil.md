---
layout: post
title: Releasing VsixUtil 
tags: vsix
---

A good portion of my free time, and not so free time, is devoted to Visual Studio extensions.  In addition to actively developing them I'm always dogfooding my extensions and those of other developers.  On any given day I probably update Visual Studio 3-5 times on various machines with new builds, proposed bug fixes, forks, etc ... 

As with any other repetitive task I like to script this as much as possible.  Building, uninstalling and reinstalling extensions is tedious work.  Much better to just write a powershell script once to do it and just keep running that.

Unfortunately there is really no good way to script the installation of a VSIX.  Scripting requires command line tools and there just isn't a good one for VSIX.  Visual Studio does come with vsixInstaller but its just not suitable for my scenario

1. Each build is tied to a version of Visual Studio.  This means it can't be xcopy deployed to a machine with an arbitrary version of Visual Studio and be expected to work.   
2. At the core it is a GUI application, it just happens to be usable from the command line.  As such it's functionaly asynchronous and can't be used for error detection.  
3. It doesn't support deployment to alternate registry hives 

The first issue is a real problem for me.  I'm not sure I have two machines anywhere with the same combination of Visual Studio installs on them.  Adding VS detection logic to every sinlge script I write to find the correct vsixInstaller isn't a maintainable solution.  I really need a tool that will just work no matter what version(s) of Visual Studio are on the machine.  

This lead me to develop a simple command line application: [VsixUtil](https://github.com/jaredpar/VsixUtil).  This is an xcopy tool that will function on a machine with any version of Visual Studio installed (even Dev14).  The command line is straight forward 

- Install: `vsixutil [/rootSuffix name] /install vsixFilePath`
- Uninstall: `vsixutil [/rootSuffix name] /uninstall identifier`
- List installed: `vsixutil [/rootSuffix name] /list [filter]`

A version of this tool has been the heart of my [https://github.com/jaredpa/VsVim](VsVim) dogfooding scripts for some time now.  Recently I decided to make it more general use to support my increased dogfooding habbits and now it is ready to be shared with others.  

Happy Dogfooding! 

- Source: [https://github.com/jaredpar/VsixUtil](https://github.com/jaredpar/VsixUtil)
- NuGet: [https://www.nuget.org/packages/VsixUtil](https://www.nuget.org/packages/VsixUtil)


---
layout: post
title: Deploying a VSIX Project to AppVeyor
---
As usual Scott Hanselman wrote a post that got me super excited about a new piece of software: [AppVeyor](www.appveyor.com).  A continuous integration system which had built in integration with github.  

VSIX projects are notorious to get working correctly.  The process which produces a VSIX depends on MSBuild tasks and targets.  Those in turn depend on the VS SDK being installed which itself depends on a full version of Visaul Studio being installed.  Puttning a full version of VS on every machine is often a blocker because who has the licences for that?  

AppVeyor uses express

xunit and x86 


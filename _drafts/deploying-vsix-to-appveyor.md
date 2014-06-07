---
layout: post
title: Deploying a VSIX Project to AppVeyor
published: true
---

As usual [Scott Hanselman](http://www.hanselman.com/) wrote a [blog post](http://www.hanselman.com/blog/AppVeyorAGoodContinuousIntegrationSystemIsAJoyToBehold.aspx) that got me super excited about a new piece of software: [AppVeyor](www.appveyor.com).  A continuous integration system which had built in integration with github.  I couldn't wait to try it out on a few projects

### Getting Builds Working

The blog post promised a simple deployment story but I was still skeptical.  Many of my OSS project are VSIX projects (Visual Studio Extensions).  These are notoriously difficult to get building in a *clean* environment because of their dependency chain

- VSIX production depends on several MSBuild Tasks and Targets
- Those targets depnd on having the full Visual Studio SDK installed
- The Visual Studio SDK depends on having Visual Studio Professional or higher installed

That last dependency is usually a killer.  Who can really afford [^1] to put a full copy of Visual Studio on every virtual machine they farm out for a continuous integration system?  

Fortunately this is a problem that AppVeyor had already [run across](http://help.appveyor.com/discussions/questions/193-visual-studio-sdk).  Their solution was simple: forgot the SDK installer, just xcopy deploy the necessary SDK bits to get VSIX builds working.  It's simple, brute force and most importantly, it works.  Well almost, there is one small change that needs to be made to the projects: deployment on build must be disabled.  The AppVeyor setup simply doesn't support this.  Turning this off requires only a one line change to the csproj.

```
<DeployExtension Condition=" '$(AppVeyor)' != ''">False</DeployExtension>
```

Once I made that small change my builds were up and running.  Literally nothing else had to change.  Pretty sweet.  

### Getting Tests Working


xunit and x86

[^1]: Except Microsoft
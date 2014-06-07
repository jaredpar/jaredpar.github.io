---
layout: post
title: Deploying a VSIX Project to AppVeyor
published: true
---

As usual [Scott Hanselman](http://www.hanselman.com/) wrote a [blog post](http://www.hanselman.com/blog/AppVeyorAGoodContinuousIntegrationSystemIsAJoyToBehold.aspx) that got me super excited about a new piece of software: [AppVeyor](www.appveyor.com).  A continuous integration system which had built in integration with github.  I couldn't wait to try it out on a few projects.

### Getting Builds Working
The blog post promised a simple deployment story but I was still skeptical.  Many of my OSS projects are VSIX projects (Visual Studio Extensions).  These are notoriously difficult to get building in a *clean* environment because of their dependency chain

- VSIX production depends on several MSBuild Tasks and Targets
- Those targets depend on having the full Visual Studio SDK installed
- The Visual Studio SDK depends on having Visual Studio Professional or higher installed

That last dependency is usually a killer.  Who can really afford [^1] to put a full copy of Visual Studio on every virtual machine they farm out for a continuous integration system?  The best most systems can do is install the various Express SKUs on the machines which isn't enough to install the SDK.   

Fortunately this is a problem that AppVeyor had already [run across](http://help.appveyor.com/discussions/questions/193-visual-studio-sdk).  Their solution was simple: forgot the SDK installer, just xcopy deploy the necessary SDK bits to get VSIX builds working.  It's simple, brute force and most importantly, it works!  Well almost, there is one small change that needs to be made to the projects: deployment on build must be disabled.  The AppVeyor setup simply doesn't support this.  Turning this off requires only a one line change to the csproj.

{% highlight xml %}
<DeployExtension Condition=" '$(AppVeyor)' != '' ">False</DeployExtension>
{% endhighlight %}

Once I made that small change my builds were up and running.  Literally nothing else had to change.  Pretty sweet.  

### Getting Tests Working
Visual Studio is still a 32 bit application.  This dependency extends even into a set of the managed DLLs that VSIX projects depend on.  As such my unit tests only properly function when run in 32 bit mode.  

All of my tests are written in xunit and right now AppVeyor only has support for running the 64 bit version.  This was causing all of my unit tests to fail out of the box.  Working around this is easy enough though.  Just check in a copy of the x86 xunit runner to your repository and change the [appveyor.xml](https://github.com/jaredpar/VsVim/blob/master/appveyor.yml) file to manually invoke the tests.  

{% highlight yaml %}
test_script:
  - Tools\xunit.console.clr4.x86.exe Test\VimCoreTest\bin\Debug\Vim.Core.UnitTest.dll /silent
  - Tools\xunit.console.clr4.x86.exe Test\VimWpfTest\bin\Debug\Vim.UI.Wpf.UnitTest.dll /silent
  - Tools\xunit.console.clr4.x86.exe Test\VsVimSharedTest\bin\Debug\VsVim.Shared.UnitTest.dll /silent
{% endhighlight %}

I alerted AppVeyor to this problem and are [looking into it](http://help.appveyor.com/discussions/questions/311-x86-version-of-xunit).

Overall I'm really happy with using AppVeyor as the CI system for my OSS projects.  The setup is easy, the team is very responsive to questions and customizing the environment is very straight forward.  

[^1]: Except Microsoft

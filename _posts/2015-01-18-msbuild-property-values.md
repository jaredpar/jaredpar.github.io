---
layout: post
title: Determing MSBuild property values
tags: [msbuild]
---
Debugging MSBuild is usually a three step process:

1. Turn on diagnostic verbosity (`/v:diag`).
2. Piping the gargantuan amount of MSBuild output to a file.
3. Using your favorite text searching tool to find that one line necessary to diagnose the problem. 

This method is effective but laborous.  However this method really only works if the build file can get to the point of processing `<Target>` elements.  If MSBuild fails before that even `/v:diag` will fail to output much, if any, information.  

When MSBuild fails that early it's typically because of malformed elements such as an empty `Project` attribute on `<Import>` element.  Happens most often when the project file isn't accounting for all the possible values of the input MSBuild properties.  But with `/v:diag` procuding no helpful output it's hard to determine what the actual value of the troublesome properties are. 

In that situation the following really simple trick can be used to print out the property values.  Simple replace the contents of the build file in question with the following: 

``` xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Target Name="Build">
    <Message Text="VisualStudioVersion value is '$(VisualStudioVersion)'" />
  </Target>
</Project>
```

This takes the malformed elements out of the equation and sets the `Build` target to just print out the values in question.  It's printf style debugging but it's simple and effective.   


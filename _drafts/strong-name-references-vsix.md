---
layout: post
title: Use strong name references in a VSIX project
tags: [vsix, MEF]
---

If you create a VSIX project using the most recent version of Visual Studio on your machine it will spit out a reference section in your project file containing the following:

``` xml
<Reference Include="Microsoft.VisualStudio.CoreUtility" />
<Reference Include="Microsoft.VisualStudio.Text.Data" />
<Reference Include="Microsoft.VisualStudio.Text.Logic" />
<Reference Include="Microsoft.VisualStudio.Text.UI" />
<Reference Include="Microsoft.VisualStudio.Text.UI.Wpf" />
```

This inocuous looking section can be the source of major debugging pain down the road.  It is one of the first items you should change when creating a VSIX project.  

This section is referencing VS SDK DLLS in a non-strong name fashion.  This means any DLL with a matching assembly name can satsify the reference independent of what version it may be. The 2010 VS SDK assemblies can satisfy it as easily as the 2015 VS SDK assemblies.  Which DLL gets chosen as the reference here is purely up to MSBuild + VS SDK targets files [^1] and they prefer newer Visual Studio SDKs over older ones.  For example on a machine with Visual Studio 2013 and 2015 MSBuild will always prefer the 2015 SDK even if you are developing in 2013.  

In general this isn't a problem because developers tend to use the most recent Visual Studio instance on their machine for active development hence the versions line up (by pure coincedence).  Developers eventualy get into trouble though when one of the following happens:

- They install a new Visual Studio version, say Visual Studio 2015, on their machines
- The original developer, or another person wanting to contribute, clones the project onto a machine with a newer version of Visual Studio
- Project starts running on a CI system like [AppVeyor](http://appveyor.com) which has every version of Visual Studio installed

When any of these happen the developer will F5 their VSIX project using the older version of Visual Studio and be greeted with a MEF composition error.  Nothing has changed in the source code of their project but suddenly it no longer works.  Even stranger is that the project will continue to work on other machines.  It's a highly frustrating situation that usually leads to several rounds of MEF debugging.

What is happening here is that MSBuild is satisfying the assembly references with the newest VS SDK.  They have a higher priority and because the reference is using a weak name MSBuild will pick it as the winner.  These assemblies are all backwards compatible so the build succeeds.  The F5 operation though will still launch Visual Studio 2013 and the 2013 editor assemblies.  Eventually this will lead to a type load error because your VSIX is bound to 2015 assemblies and there is no binding redirect in place.  

The fix for this problem is very simple: use a strong name when defining VS SDK references. 

``` xml
<Reference Include="Microsoft.VisualStudio.CoreUtility, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a, processorArchitecture=MSIL" />
<Reference Include="Microsoft.VisualStudio.Text.Data, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a, processorArchitecture=MSIL" />
<Reference Include="Microsoft.VisualStudio.Text.Logic, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a, processorArchitecture=MSIL" />
<Reference Include="Microsoft.VisualStudio.Text.UI, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a, processorArchitecture=MSIL" />
<Reference Include="Microsoft.VisualStudio.Text.UI.Wpf, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a, processorArchitecture=MSIL" />
```

This reference can never be ambiguously matched: it will either bind to the 2010 VS SDK assemblies or MSBuild will issue an error.  Making this change will save you many headaches and hours of MEF debugging on your VSIX project.  

[^1]: To keep it simple I'm going to refer to the combination as MSBuild in the rest of the post

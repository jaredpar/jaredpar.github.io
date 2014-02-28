---
layout: post
---
Visual Studio 2012 introduced [project file round
tripping](http://blogs.msdn.com/b/visualstudio/archive/2012/03/28/round-
tripping-with-visual-studio-11.aspx) feature.?? This lets developers edit the
same project in Visual Studio 2010, 2012 and 2013 without the need to upgrade
the project file or modify it in any way.?? This was a highly requested feature
by customers that allowed them to edit their project no matter what version of
Visual Studio they had on their machine.?? The previous forced upgrade model
for new versions was a big adoption blocker.?? Now customers can just grab the
latest Visual Studio version and start hacking away

Unfortunately this feature [does not
work](http://blogs.msdn.com/b/zainnab/archive/2012/06/05/visual-studio-2012
-compatibility-aka-project-round-tripping.aspx) on all project types including
VSIX projects.?? This meant that Visual Studio Extension authors who wanted to
developer extensions for all versions of Visual Studio were essentially locked
into editing that code with 2010.???? This is doubly unfortunate given that
extension authors are the type of developers most likely to early adopt new
versions of Visual Studio.

The good news though is that it is possible to have a VSIX project be round
tripped, it just requires a bit of special sauce to get working.?? Once done
though a VSIX project can be fully edited, F5???d, etc ??? in any version of
Visual Studio.

Originally this blog post was going to be a step by step process for getting a
2010 VSIX project into full round tripping mode.?? However as I started to
write the post it was looking rather dull.?? Virtually every line was a variant
of

  * Open File <???>
  * Paste <this odd snippet> on line <???>

After pasting some rather ugly MsBuild XML into my post I realized that there
was a much better way to convey this information: actually demonstrating the
transition from a 2010 extension to a fully round trippable one on a real
project.?? Essentially I decided the best way to do this was to speak in code.

Hence I created a GitHub project that starts with a simple 2010 extension and
step by step (or commit by commit) turns it into a fully round trippable one.
Every commit has detailed comments about why the edits were taken, what
features they provide and what limitations remain. The full transition is
available here

  * GitHub Project: <https://github.com/jaredpar/RoundTripVSIX>
  * Commit Log: <https://github.com/jaredpar/RoundTripVSIX/commits/master>

I hope that this speaks better to other extension developers out there and
helps them get to a happy round trippable world.


---
layout: post
title: Round Trippable VSIX Project Templates
---
A short time ago I [wrote a post]({% post_url 2013-12-04-round-tripping-a-vsix-project %}) about how to turn a standard VSIX project into one which could be round tripped into any version of Visual Studio.  This set of changes also fixed other issues like debugging + SCC, assembly binding, etc ...  I got a lot of positive feedback and nice links to projects that developers upgraded as a result of my post. 

While this was working great for developers with existing projects it still amounted to routine extra work for developers creating new VSIX projects.  They either had to

1. Copy the [RoundTripVSIX Source](https://github.com/jaredpar/RoundTripVSIX) locally and do a bunch of renaming 
2. Create a new VSIX project and mirror the exact edits listed in the previous post 

A much better solution would be for me to publish new VSIX project templates that are round trippable to the gallery.  With that developers can just do the normal File -> New Project -> Round Trip VSIX and be up and running immediately.  

Originally I didn't do this because authoring and packaging project templates was a rather involved effort.  I just didn't have the time necessary to learn it well enough to ship a good product.  Recently though I was reading about the [Side Waffle](http://sidewaffle.com/) project.  Its promise of making project / item template creation as easy as creating the project was very appealing.  

Yesterday I had an hour of free time and decided to take Side Waffle for a spin.  Man did it deliver on its promise.  I installed the Side Waffle extension, watched a [5 minute tutorial](https://www.youtube.com/watch?v=NChUqnArTrI&feature=youtu.be) and had my first version of the templates running just a few minutes later.  Their promise of easy template creation was spot on.  I frankly have no idea how the underlying packaging mechanism works but I've succesfully created a number of templates at this point (basically the opposite of what I expected).  

The fully round tripping templates are now available on the Visual Studio Gallery and in source form.  Contributions and suggestions are always welcome! 

- VSIXTemplates on [Visual Studio Gallery](http://visualstudiogallery.msdn.microsoft.com/8bdcdbea-5d10-4a77-adaa-7d8ac6fcd9f8?SRC=Home)
- VSIXTemplates source on [Github](https://github.com/jaredpar/vsixTemplates)

---
layout: post
title: Experiences using F# in VsVim 
tags: [fsharp, vsix]
---

I'm often asked why I chose to write VsVim in F#.  Or particularly why did I write it in a mix of F# and C# instead of just picking one language and going with it

# Why did I chose F# for VsVim? 

I started working on VsVim at the end of the Visual Studio 2010 release cycles.  That particular release cycle was easily the toughest I've ever went through and towards the end I was approaching a major burn out.  I needed a fresh new side project to give me some release [^1].  

When I took a step back to look for a project to start on there were a couple of brand new items in Visual Studio that interested me:

- WPF editor and MEF extension model
- A functional .Net language named F#

Both of these were shiny new toys that looked like they needed to be experimented with.  

F# in particular intrigued me.  The language team sat just down the hall from me and through the 2010 release cycle I'd gotten to know them pretty well.  They were all smart, engaging developers eager to chat about what they were doing.  The language itself looked very appealing and the fact that I had 0 practical experience with functional programming seemed like a problem worth fixing.

I stared by writing a couple of toy programs in F# and this only increased my interest in the language.  Very quickly I settled on the idea of using F# for my vim emulator.  

# The learning curve 

As I stated before I had 0 practical, and really any, experience using a functional language.  My background was a heavy dose of C/C++ and Java.  F# was a brand new world for me and I was determined to dive in full board. 

That pretty quickly backfired on me.  This was before Visual Studio 2010 was released and hence F# documentation was still very thin and there were very few samples to draw from.  I was spending all of my time trying to translate complex C# COM interop and WPF into F#.  It was painfully slow and eventually it forced me to divide up the project: 

- F# for the core vim logic 
- C# for WPF and VS shell integration

This break down let me to focus on doing algorithms in F# and all the WPF / interop code in C# where I could mostly copy existing patterns.  

Even with the reduced scope progress was still slow.  The syntax was strange, well known types had funny names, signature files were odd and heavy use of type inference and _ values made the very samples that did exist concise but also difficult to follow.  My main guide was [Brian McNamara's blog](http://lorgonblog.wordpress.com/) whose samples I tried to emulate in style and approach but it was rough sledding.  

It took a couple weeks before I could code for a solid 10 minutes without jumping back to the F# spec for help.  After a month the language started feeling a bit more comfortable and I was able to focus a good deal more on the algorthimns.  About 3 months in though is when F# finally clicked for me.  

The downside of this click moment though was realizing everything I'd written up to that point was now sub-standard and needed to be completely rewritten. 

# Open source contributions

Overall I was really happy with the decision to use F#.  Before VsVim I didn't have significant experience with functional programming.  Using functional programmnig at this scale long term affected the way I think about programming.  It has simply changed the way that I code C# 

The one significant downside to using F# was an adoption blocker for OSS contributions

Early on F# was not a universal win because it represented a blocker to OSS contributions.  This may seem strange given how much the F# language has exploded in popularity in recent times.  However when I started VsVim F# was a brand new language (for several years VsVim was one of the largest OSS F# code bases).  

The lack of samples, documentation and general newness of the language turned off possible contributers.  It was not uncommon at all for me to get a couple emails a month along the lines of

> Man I'd love to contribute and help out with that bug but I just don't know anything about F#

The problem was severe enough that ~2 years into the project I had serious thoughts about rewriting in C#.  Even though I was really happy with the language being the sole significant contributor to the project wasn't a prospect I was looking forward to.

But then the tide started turning doing so relatively fast.  As the community around F# grew up the documentation got better, F# talks started showing up at conferences, more OSS projects came into existance and suddenly more developers were sending me patches.  

The really interesting part is that most of the developers still hadn't written F#.  But suddenly they were willing to take the plunge and learn enough of the language to get their fixes submitted.  I can only presume this is because the language simply appeared more mainstream and developers felt like it was a valuable use of their time to learn the language.  

# Deploying the runtime

The 

VS is strange 

[^1]: Because when you're burnt out coding another coding project is a great way to releax ;) 



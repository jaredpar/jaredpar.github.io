---
layout: post
title: Why did I write VsVim in F#? 
tags: [fsharp, vsix]
---

I'm often asked why I chose to write VsVim in F#.  Or particularly why did I write it in a mix of F# and C# instead of just picking one language and going with it


This was not a decision that I was universally happy with

Overall I was really happy with the decision to use F#.  Before VsVim I didn't have significant experience with functional programming.  Using functional programmnig at this scale long term affected the way I think about programming.  It has simply changed the way that I code C# 

The one significant downside to using F# was an adoption blocker for OSS contributions

Early on F# was not a universal win because it represented a blocker to OSS contributions.  This may seem strange given how much the F# language has exploded in popularity in recent times.  However when I started VsVim F# was a brand new language (for several years VsVim was one of the largest OSS F# code bases).  

The lack of samples, documentation and general newness of the language turned off possible contributers.  It was not uncommon at all for me to get a couple emails a month along the lines of

> Man I'd love to contribute and help out with that bug but I just don't know anything about F#

The problem was severe enough that ~2 years into the project I had serious thoughts about rewriting in C#.  Even though I was really happy with the language being the sole significant contributor to the project wasn't a prospect I was looking forward to.

But then the tide started turning doing so relatively fast.  As the community around F# grew up the documentation got better, F# talks started showing up at conferences, more OSS projects came into existance and suddenly more developers were sending me patches.  

The really interesting part is that most of the developers still hadn't written F#.  But suddenly they were willing to take the plunge and learn enough of the language to get their fixes submitted.  I can only presume this is because the language simply appeared more mainstream and developers felt like it was a valuable use of their time to learn the language.  







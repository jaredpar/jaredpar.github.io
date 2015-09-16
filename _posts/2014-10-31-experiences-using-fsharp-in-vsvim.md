---
layout: post
title: Experiences using F# in VsVim 
tags: [fsharp, vsix]
---

A few days ago while discussing VsVim with a coworker it occured to me that I'd been working on this project for 5 years now.  It was a bit startling for me because it feels like just yesterday when I finally got permission to release it to the public.  After reflecting for a few minutes I decided that I wanted to write a couple of posts on this project and how it shaped up over time.  

What better place to start than how F# impacted this project?  

# Why did I choose F# for VsVim? 

I started working on VsVim at the end of the Visual Studio 2010 release cycles.  That was easily the toughest release cycle I ever went through and towards the end I was approaching a major burn out.  I needed a fresh new side project to give me some release and boost my morale[^1].  

When I took a step back to look for a project to start on there were a couple of brand new items in Visual Studio that interested me:

- WPF editor and MEF extension model
- A functional .Net language named F#

Both of these were shiny new toys that looked like they needed to be experimented with.  Why not just use both in the same project?  

F# in particular intrigued me.  The language team sat just down the hall from me and through the 2010 release cycle I'd gotten to know them pretty well.  They were all smart, engaging developers who were eager to chat about what they were doing.  The language itself looked very appealing and the fact that I had 0 practical experience with functional programming seemed like a problem worth fixing.

I stared by writing a couple of toy programs in F# and this only increased my interest in the language.  Very quickly I settled on the idea of writing a small vim emulator extension in F#.

# Embracing the language 

As I stated before I had 0 practical, or really any, experience using a functional language.  My background was a heavy dose of C/C++ and Java with a side helping of scripting.  F# was a brand new world for me and I was determined to dive in full force. 

That pretty quickly backfired on me.  This was before Visual Studio 2010 was released so F# documentation was still very thin and there were very few samples to draw from.  I was spending all of my time trying to translate complex C# COM interop and WPF into F# using nothing but the language spec.  It was painfully slow and eventually forced me to divide up the project: 

- F# for the core vim logic 
- C# for WPF and VS shell integration

This break down let me to focus on doing algorithms in F# and all the WPF / interop code in C# where I could mostly copy existing patterns.  Now I could focus on actually learning F#.

Even with the reduced scope progress was still slow.  The syntax was strange, well known types had funny names and were in the wrong place, signature files were odd and the heavy use of type inference and _ values made the few samples that did exist difficult to follow.  My reliable guide through this process was the F# spec and [Brian McNamara's blog](http://lorgonblog.wordpress.com/) whose samples I tried to emulate in style and approach.  Overall though it was very rough sledding. 

It took a couple weeks before I could code for a solid ten minutes without jumping back to the F# spec or email for help.  After one month it started getting better and I was spending less time fighting the syntax and more time working on algorithms.  The progress was slow but steady.

The real change came about 3 months in when F# finally clicked for me.  Suddenly I wasn't translating F# anymore I was thinking in it.  That's when my productivity started to soar and I really began to leverage F# to make my code better:

- Find a place where the editor API sometimes return null?  Wrap the return in an `option` type. 
- Tons of nested `match` blocks?  Simplify with a maybe monad.
- Function too complex?  Leverage lambdas as nested functions.
- Types too intertwined?  Break them apart with signature files. 
- Null reference exceptions?  None of that going on here. 
- Immutable values whenever possible. 
- Discriminated unions for so many scenarios.

Discriminated unions in particular were a mental revolution for me.  Enums with type safe state is a feature I'd long craved in other languages but never had a name to attach to it.  I've since found countless uses for them in F# and miss them terribly when I'm in any other language.  If I could add one and only one feature from F# back to C# this would be it.  

Once I started thinking in F# there was really no turning back.  It was still about six months in before my F# productivity matched that of C# but the flexbilitiy and expressiveness of F# more than made up for the gap.  

# Open source contributions

The one area where F# did not shine for me was OSS contributions.  The desire to contribute to VsVim was there but developers often saw F# as a barrier to contribution.  Several times a month I would get emails along the lines of:

> Man I'd love to contribute by fixing that bug but I just don't know anything about F# 

This may seem strange now given F#'s rise in popularity but at the time it was a brand new language.  The documentation was still weak and there weren't a lot of real world sample code bases to draw from [^2].  The language was a barrier developers didn't want to cross. 

The problem was severe enough that ~2.5 years into the project I had begun to outline a plan to convert all of my F# to C# over the course of a couple releases.  I was very happy with the language but the prospect of being the sole significant contributor to the project over the long term wasn't something I was looking forward to. 

But then the tide started turning and doing so relatively fast.  As the community around F# grew up the documentation got better, F# talks started showing up at conferences, more OSS projects came into existance, great blog series were written and then suddenly developers were sending me patches.  

The really interesting part is that most of the developers still hadn't written F#.  But now they were willing to take the plunge and learn enough of the language to get their fixes submitted.  I can only presume this is because the language simply appeared more mainstream and developers felt like it was a valuable use of their time to learn the language.  Whatever the reason though I couldn't be happier.  

I think F# is still attaches a higher bar to contribution than C# does, but that bar is significantly lower now and getting lower every day.  

# Looking back

When I look back on my experiences with F# I'm amazed at how much learning it changed me as a developer.  I already had a strong focus on correct, testable, maintainable code with a strong focus on simple, maintainable types / functions.  F# taught me to simplify even further by seeing types as data instead of a collection of behaviors.  Sure there is a place for mutating objects but I now default to seeing them as data first and behavrios only when it really makes sense in the greater context of the program.  

It also showed me how a type system can be used, and sometimes abused, to create more robust APIs.  Unfortunately concepts like non-null, discriminated unions and the like don't map well in C#.  But it is possible to take smaller steps like embracing call backs, using default values instead of null, leveraging immutable types etc ...  

I think the best way to summarize how I feel about F# is that it's changed the way I approach coding in other languages.  This is true from C# to C++.  I couldn't be happier that I decided to write VsVim in F#.  If you're starting a .Net project soon and have never used a functional language I highly suggest you give it a try as well.  

[^1]: Because when you're burnt out coding another coding project is a great way to releax ;) 
[^2]: For a long time VsVim was one of the largest OSS F# projects



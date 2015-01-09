---
layout: post
title: Looking forward to a better StyleCop
tags: [misc]
---
A consistent coding style is one of the most undervalued components of a maintainable code base.  Code should always be optimized for readability as developers spend far more time reading code than writing it.  Having a consistent style helps here because it establishes conventions and locations for well known programming elements.  

When taken individually items like the naming of fields, the position of braces, the casing of names, etc ... are all small neglible issues.  Any time spent debating which is right or wrong is time that could be better spent doing virtually anything else.  Yet when these items are taken as a whole they serve to create a dialect within the language. 

Just as it's hard to understand someone speaking in a dialect that differs from your own, it's hard to read code that significantly differs from your dialect.  Or at the very least, it slows down the reading process.  

This gets even harder as the number of styles within a code base increases.  Juggling two styles is annoying but once you're juggling five it's a real hamper to productivity.  Code bases with no enforcement end up with as many styles as there are developers.  It only takes a few years before that number gets into the teens and the code is as messy as a college dorm room.  

Coding styles help prevent this by defining a single style for the entire project.  It makes the transition between files as smooth as possible because it lets deveolpers focus on what the code is saying, not how it is saying it. 

A coding style though is worthless unless it is ruthlessly enforced.  Developer diligence is simply not a good method of enforcement here.  Coding styles can be highly contenious issues and having to constantly square off over them on code reviews and with new hires is a mentally draining activity.  Over time the diligant developers wear down and the code once again begins to devolve into personal preference. 

This is why I'm an unabashed lover of StyleCop.  It is simply the best tool around for defining and enforcing style guidelines in a code base.  It can be run on the command line, in the IDE and as a part of a checkin verification system.  This removes the need for developers to constantly square off over the issue.  Get the style right or your change simply won't pass the necessary tests. 

As much as I like StyleCop though I'm enormously frustrated by it when I have a build fail because:

- Didn't add a space between an `if` and a `(`.
- Had an extra newline at the end of the file. 
- Put a brace on the wrong line. 
- Namespaces weren't sorted correctly. 

All I wanted to do was F5 my latest change and see if it fixed the bug I was working on.  But before I can test out a functional change to the source tree I need to spend a few precious minutes making style edits to my code.  Why is this silly style issue blocking me from testing my change??? 

I often find annoynances like this are the root of opposition to enforcing style guidelines in a code base.  Developers are fine, even if it's reluctantly, with having a coding style, they just don't want to be constantly fighting the tools to make changes. 

And they are right to feel that way.  Fixing style issues is a task that can be easily automated.  They are right to be annoyed that the IDE isn't just fixing this problem for them. 

Looking forward I'm hoping we can extend StyleCop like tools to be multipurpose:

1. Detect style violations.
2. Fix style violations.

I often like to refer to #2 as StyleBoss: don't nag me about the problems in my code, just go out there and fix them for me. 

Many of the fixes to style violations don't require complex solution wide analysis; just a parser and code generation API [^1].  These changes amount to little more than code formatting and should be applied in the same way.  Have StyleCop hook into well known formatting hooks and just fix my style violations as I type. 

And I don't mean add a smart tip for every violation.  Initiating the fix still requires developer interaction and itime.  Just fix the code without even bothering me.  

- Save a file: fix the style violations as a part of the save.
- Close a method brace: fix the style violations just like you'd format the method.

Not all style fixes are simple enough to be done implicitly.  Those more explicit ones could be done in batch via an explicit IDE command.  Or from a command line tool that runs over a solution. 

This is the tools that I'm looking forward to.  Pick a style and don't make me constantly have to think about it.  Just make it happen for me. 

[^1]: Can you say Roslyn? 

===

It's a task that could easily be done on file save.  This would take away so many of the annoyances without changing the underlying functionality.  

Yes style enforcement would still need to be run as part of check in suites.  

They are right to feel that way.  Style changes are a task that is very automatable.  It doesn't require complicated soolution wide analysis.  It just needs a parser, and a way to spit out changes to the parse tree.  This is a task that can easily be done on file save.  This would take away so many of the annoyances without changing the function of the tool. 

I often find these little annoyances like this are what turn developers off on tools like StyleCop.  It is constantly warning them about violations that the tool is capable of just fixing itself.  Fixing all these violations in a mind numbing repetitive task.  Why not just have the style tool fix it for me every time I save?  

Fixing style issues doesn't require a complex solution wide analysis.  It just requires a parser and a simple rewriting API.  This type of operation can easily be done on every save.  

Sure these are style violations but now I've wasted precious coding time thinking 

Fixing style errors is a mindless, repetitive task best done by a dedicated tool. 

These are non-functional issues that are blocking me from checking in.  How dare they!!! 

What's doubly madenning is these are issues the tool should be fixing for me.  Styl
Detecting and fixing issues of this nature doesn't require a complex analysis of the solution, it just requires a parser and a rewriter.  



But what's more maddenning is these are issues the tool should be fixing for me.  Fixing style issues of this nature doesn't required a complicated analysis of a solution.  It just

None of these are functional issues and yet my build is broken.  Worse off is all of these issues are easily fixable by the tool itself.  There is no thought that needs to go into the fix, no trade off of size or performance.  It's a simple edit operation that the tool is nagging me to do (over and over again).  

This is why I feel like so many developers get turned off by tools like StyleCop.  It's constantly asking the developer to do things it could automate away.  

None of these are functional issues and yet my build is broken.  Worse all of these issues are 

And yet I'm also often enormously frustrated by it when I have a build or checkin fail with one 

It also sets the standard for new developers 


Code is read far more often than it is written and having a consistent style goes a long way to making it more readable.  It makes the transition between your code and other developers code as smooth as possible because the algorithms need to be processed, not the structure of the code around it.  



This probably seems like little more than an annoyance to developers who have worked on small code bases.  

This seems like a small thing until you've worked in a code base that has no style guidelines.  The tranistion 

This is why I am an unabashed lover of StyleCop.  It is simply the best tool around for defining 


I am an unabashed lover of StyleCop.  Consistent style is a imporant, yet undervalued, component of writing maintainable code.  

The majority of code I write is in C# and StyleCop is simply the best tool out there for enforcing a consistent style.  

Don't get me wrong, I absolutely love StyleCop.  Consistent style is an important component of maintainable software.  StyleCop, and tools like it, are  simply the best tool available for enforcing consistent style in code base. 

But the StyleCop flavor of tools have a major flaw: at times they are really annoying to use. 

I can't count the number of times I've had a check-in rejected or a build failed because of a small style infraction:

- Forgot to add a copyright notice.
- Didn't add a space between an `if` and a `(`. 
- Put a brace on the wrong line.

Having a build fail for such a minor infraction is downright madenning.  Or having the IDE cluttered with failures. 

Many people point to this as a reason to abandon StyleCop.  I completely reject that approach.  Consistent style is the right approach, the problem here is the tooling.  Focus on fixing the problem here. 

When I think about building tools like StyleCop on top of Roslyn I don't think about emulating the exising behavior, I think about improving it. 

- Don't tell me to add a copyright, just add it. 
- Don't tell me to put a space between `if` and `(`, just put one there.
- Don't tell me to put `{` on a newline, just insert it.

When I think about moing

I think about a better StyleCop, StyleCop++ if you will.  A tool that doesn't constantly warn me about style violations but instead just makes my code have the correct style.  

These types of corections can be done safely without any reasonable risk of altering the semantic meaning of code.  


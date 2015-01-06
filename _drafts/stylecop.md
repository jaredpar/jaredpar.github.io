---
layout: post
title: Looking forward to a better StyleCop
tags: [misc]
---
A consistent coding style is one of the most undervalued components of a maintainable code base.  Code should always be optimized for readability as developers spend far more time reading code than writing it.  A consistent style helps greatly here because makes the transition between reading your code and other developers code as smooth as possible.  The reader can focus on the algorithms without having the process the style quirks of the current author.  

Items like the naming of fields, the position of braces, the casing of names, etc ... individually are small, neglible issues.  Taken as a whole though they can create a wide variety of dialects within the language.  Just as it's harder for speakers of a language to understand other dialects, it's harder for developers to read code in other dialects.  Or at the very least, slows down the reading process.  Coding styles help prevent this by defining a single dialect for all developers on a project.

A coding style though is worthless unless it is ruthlessly enforced.  Developers diligence is simply not a good method of enforcement.  Coding styles can be contenious and having to constantly square off over them on every checkin or with new hires is a mentally draining activity.  Over time the diligant developers wear down and the code once again begins to devolve into different dialects.

This is why I'm an unabashed lover of StyleCop.  It is simply the best tool around for defining and enforcing style guidelines in a code base.  It can be run on the command line, in the IDE and as a part of a checkin verification system.  This removes the need for developers to constantly square off over the issue.  Get the style right or your change simply won't pass the necessary tests. 

As much as I like StyleCop though I'm enormously frustrated by it when I have a build fail because:

- Didn't add a space between an `if` and a `(`.
- Had an extra newline at the end of the file. 
- Put a brace on the wrong line. 
- Namespaces weren't sorted correctly. 

All I wanted to do was F5 my latest change and see if it fixed the bug I was working on.  But before I can test out a functional change to the source tree I need to spend a few precious minutes making style based edits to my code.  Why should a style issues block me from testing out this change???  

I often find these little annoyances are what turn developers off to StyleCop.  They don't oppose having an enfoced coding style, they just don't want to be constantly fighting the tools to make changes to the source tree.  

And they are right to feel that way.  Fixing style issues is a task that is immeniently automatable.  It doesn't require any kind of complicated solution wide analysis, just a parser and a rewrite API.  Yet this silly little automatable task is stopping me from F5ing my last bug fix of the day! 

A path forward here is to extend StyleCop so that it has two purposes:

1. Detect style violations.
2. Fix style violations.

The latter task is not computationally expensive and could easily be run as part of a "Save File" operation.  Most IDEs do minor formatting changes already today.  StyleCop should be taking this operation to the next level and just apply the style instead of nagging me about it all the time. 

I often refer to this modified StyleCop tool as StyleBoss.  Don't nag me about the changes, just make it happen.  

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


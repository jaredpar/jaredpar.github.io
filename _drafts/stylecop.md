---
layout: post
title: Looking forward to a better StyleCop
tags: [misc]
---
A consistent coding style is one of the most undervalued components of a maintainable code base.  Code should always be optimized for readability as developers spend far more time reading code than writing it.  A consistent style helps greatly here because makes the transition between reading your code and other developers code as smooth as possible.  The reader can focus on the algorithms without having the process the style quirks of the current author.  

Items like the naming of fields, the position of braces, the casing of names, etc ... individually are small, neglible issues.  Taken as a whole though they can create a wide variety of dialects within a given language.  And just as it's often difficult for speakers of the same language to understand other dialects, it's difficult for developers to understand other written dialects.  Or at the very least, slows down the reading process.  Coding styles help prevent this by defining a single dialect for all developers on a project to speak.  

A coding style though is worthless unless it is ruthlessly enforced.  Developers diligence is simply not a good approach to this problem.  Coding styles can be contenious and having to constantly square off over them  on every checkin or with new hires is a mentally draining activity.  Over time the diligant developers wear down and the code begins to diverge.  

This is why I'm an unabashed lover of StyleCop.  It is simply the best tool around for defining and enforcing style guidelines in a code base.  It can be run on the command line, in the IDE and as a part of a checkin verification system.  This removes the need to constantly square off over the issue.  Get the style right or your change simply won't be accepted.  

As much as I like StyleCop though I'm enormously frustrated by it when I have a build or checkin fail because:

- Didn't add a space between an `if` and a `(`.
- Had an extra newline at the end of the file. 
- Put a brace on the wrong line. 
- Namespaces weren't sorted correctly. 

None of these are functional issues and yet my build is broken.  Worse off is all of these issues are easily fixable by the tool itself.  There is no thought that needs to go into the fix, no trade off of size or performance.  It's a simple edit operation that the tool is nagging me to do (over and over again).  

This is why I feel like so many developers get turned off by tools like StyleCop.  It's constantly asking the developer to do things it could automate away.  

None of these are functional issues and yet my build is broken.  Worse all of these issues are 

And yet I'm also often enormously frustrated by it when I have a build or checkin fail with one 

It also sets the standard for new developers 

===
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


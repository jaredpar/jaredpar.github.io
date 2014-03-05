---
layout: post
---
Nothing revolutionary about that statement. Yet I keep reading the opposite on various comment threads and message boards so I thought it a good idea to explore it again.

Code is not self documenting.

The "code is self document" argument often comes up when commenting conventions, patterns and overall usage is discussed. People who are typically against writing more than the existing set of comments will throw out the argument "if we need a comment then the code should be written to be self documenting."

To at extent I agree with this. Code should not be obfuscated and the usage should be clear. I personally strive to make my implementations as clear as possible and enforce that belief on anyone who asks me for a code review.  

Yet while you can write code so that an individual algorithm or function is close to self documenting you cannot write it in such a way that it will explain it's greater purpose in a program. Only comments can do that. Self describing code can only describe itself, not it's purpose in the bigger picture.

Comments serve to both 1) explain the algorithm and 2) explain the greater purpose of the algorithm in the program.

Yet people still cling to the code is self documenting mantra. In my experience there are several reasons for this belief.'? The first is that people have only worked on projects small enough that for most purposes they can be kept entirely in their mind [*]. Until you work on a big enough program #2 is not even a factory because you intimately understand how every function fits into the big picture.

Another is that they have never worked on a project with people they weren't very familiar with. People you don't know well or have worked with before will likely have different ways and practices of approaching a problem which you have not encountered before. What is obvious to them won't be obvious to you. The bridge between these approaches are comments.

I've seen DRY (don't repeat yourself) brought up as well [**]. The code clearly says what it does so adding a comment is just repeating yourself. I find that to be patently untrue. If we're even having the conversation then the code is clearly not self documenting. Also in the cases when an individual function is documenting you will still run into #2.

Commenting your code benefits both people who are reading your code and yourself. You will eventually come to a point where you've forgotten what a particular piece of code did or how it fit into your bigger program. Your comments will save you.
    
    [*] The temptation to say "kept in memory" here was huge but I avoided it.


    [**] In general I think that DRY is a great approach to programming but I feel it's being taken to far here


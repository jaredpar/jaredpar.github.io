---
layout: post
title: Should just anyone be allowed to use lock? 
---

I spend a lot of time reviewing code and one thing I'm constantly on the lookout for is uses of *lock*.  Multithreaded code is really, really hard to get correct.  Doing so forces your brain to operate in ways that just aren't natural.  

As someone who has taken over code in the past I don't want anymore being checked in 

Yet virtually every day I see a new use of *lock* being sent out.  What disturbs me the most is that this happens with virually no oversight.  It's generally newer developers who are both sending out and signing off on the review.  Basically the developers with the least experience checking in some of the most complex code possible.  The other day I sat back and wondered if this was really the best way to do things.

 

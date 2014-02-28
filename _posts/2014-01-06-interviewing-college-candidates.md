---
layout: post
---
Lately I've been reading a lot about peoples interview processes and it
inspired me to share my process for interviewing college candidates.  I've
been doing interviews at Microsoft for ~10 years now and developed this
process over that time.  The format for the interviews are typically 1 hour
with just me and the candidate.  Usually in my office or occasionally a
conference room.  Unfortunately 1 hour is a very short amount of time in which
to judge a candidate and I try to combat that by planning ahead and working
with the below process.

Note that this post is specifically about how I interview college candidates
or candidates with a small number of years in the industry.  I have a much
different process for senior level developers (which is more of what I do
these days).

## Pre Interview Setup

The candidate deserves my undivided attention during the interview.  Before I
go out to greet the candidate I turn my phone off and put it in my desk, close
my email, turn off the speakers to my computer and lock the screen.  The only
visible distraction I have is a clock to make sure I'm keeping the interview
moving along.

## The Introduction

My very first goal in an interview is to make sure the candidate is
comfortable in the environment. Interviewing is a nerve racking experience for
some people (especially college candidates who are quite possibly doing this
for the first time ever).  I'm rarely the first person on an interview loop
and hence I often have to deal with candidates that are tired or perhaps
rattled a bit by an interview earlier in the day.  I find people perform best
when they are in a relaxed environment and I do my best to get them there.

One technique I've found that helps relax people is to get them talking about
something they are passionate about.  I get every candidates resume a day or
two before the interview and I look over it in detail.  I'm looking for
anything that they have put significant time or effort into: a senior project,
GitHub contributions, stack overflow, etc ???

Once I find that project I spend 30 minutes or so researching it myself.  My
goal is to get enough of an understanding of the project that I can have a
conversation about it.  I also write down some really easy questions about the
project.  Presenting the candidate with questions on subjects they are
passionate about is a good way to get the candidate relaxed and give them an
early confidence boost.  It's much better then starting them off with
questions I'm passionate about

I usually start off with the standard small talk.  Who I am, how long I've
been here and what groups I've worked in at Microsoft.  I ask them the same
about themselves and then transition into the research I've done on them

> I was looking over your resume and noticed your senior project on improving
TCP startup.  Tell me about that.

Some people are happy to go on at length here and some are a bit more
reserved.  For the reserved I prompt them with the questions I've already
written down.

> Why is TCP intentionally slow at startup?

>

> Your project focused on improving algorithm X, what was wrong with it?

Remember the goal here is to relax the candidate and increase their
confidence.  Take their project, craft easy questions for it based on the work
their project said they did.  Let them shine here.

I generally reserve 10-15 minutes for this section of the interview

## The Technical Interview

I start the technical portion off with a very easy and vaguely worded
question.  My favorite question is the following

> Write a function that takes a collection of letters and determines if there
are any duplicate letters

The candidate is free to constrain this problem however they like

> Can I use a hash table?  Sure

>

> Can I assume the letters are all ASCII? Sure

>

> Can I assume they come in sorted order? Sure

>

> Can I sort them? Sure

>

> Can I use something like bubble sort to check every combination? Sure

I do this for a couple of reason.  In part I want to keep the candidate
comfortable and give them an easy win on the white board.  I don't care how
they solve it, just that they can solve it.  It's a modified fizzbuzz problem
that tells me they can at least write code in the language of their choosing.
The other reason I do this is because I'm curious to see what questions they
will ask (if they ask any).  What they ask often reveals a good deal on how
they approach coding.

After they get the solution correct and we walk through it I start taking
things away.

> That hash table makes it easy doesn't it?  How would you solve it without a
hash table?

>

> ASCII really makes the problem easy.  How would you solve it with Unicode
characters?

>

> Could you solve this without allocating any memory?

I make subtle changes to the question that make the solution **incrementally**
harder and gauge how they react to the changes.  I do want to stress
incrementally here.  I don't go from easy to hard with a single twist.
Instead I add constraints to gradually and incrementally up the difficulty.

It's not critical that they solve every twist I give them.  Really what I'm
after here is how they think about coding and whether or not they can adapt
their solution to changing requirements (aka my life as a programmer).  I'm
also curious how they react on a personal level to the changes.  Do they get
angry, excited, etc ???

Throughout this section of the interview there is one thing I'm constantly
vigilant about

> Do **not** ever let the interview session go stale for more than 5-10
seconds

There is 0 value in having an interview where me and the candidate are just
staring at each other silently for several minutes.  If they get stuck on a
problem it is my job as the interviewer is to help get them unstuck.  Ask them
what they're stuck on, what they've considered, get them to draw out sample
input, anything that gets them talking or writing on the white board.

My time reservation for this section is 35-40 minutes but I'm a bit more
flexible.  If the candidate is a clear hire I usually stop earlier and spend
more time on selling, answering questions.  If a candidate is struggling I
give them as much time as possible to get to a good solution.

## The Wrap Up Conversation

In general I let the interview wrap up be very candidate driven.  I open the
floor for questions they have.  If they don't have any I try and answer the
most common questions

  * What is the environment in my group like
  * What are the ups and downs of my group
  * What is life in Seattle like
  * Why did I pick Microsoft over company X

It is really important in the wrap up to make sure the candidate leaves
feeling good about the interview.  Even if the candidate completely and
utterly screwed up the interview I try to make sure they leave feeling good
about the session.  They could have just had a bad day, you may have just
asked them the one question they couldn't answer.  It's very possible that you
are the only "No Hire" they will get all day long.  Or maybe they're not good
enough now but a year from now they've gotten enough better that they nail the
interview and you end up working with them.

To sum it up in one statement ???

> Never let a candidate leave feeling bad about themselves.


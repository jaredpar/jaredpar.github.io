---
layout: post
---
... and to actively guard against yourself.

Over the years I've found that I can be my own worst enemy when I code. Part
of the problem stems from paranoia

Early in my college days, a professor of mine, Jim Greenlee, instilled in me
the virtue of paranoid programming. He taught an introduction to C class on a
Linux/Unix environment. Our code had to compile with no warnings or errors on
Linux and Unix, pass lint, and withstand all manner of evil input the TA's
could throw at it. Catching a mistake and printing out an error was bad, but
acceptable. Crashing was an immediate 0. Towards the end of the semester, I
usually wrote two programs for the each assignment: 1) the assignment and 2) a
Perl script designed to automate and generally speaking cat /dev/random into
the program.

Over time, this process led to a healthy suspicion of any code that I used
(not so much my code, but code I didn't own or didn't actively work in). As a
result, I now rarely make assumptions about how other people's code works. I
probe, search, test and investigate any assumption about resource management,
lifetime, etc . When I'm working on my code, however, I tend to assume I got
it right and followed such patterns as RAII. And therein lies the problem: no
one is perfect, and I should be as paranoid about the quality of my code as
anyone else's.

I find this problem happens most often on the border of my code and the rest
of the program. I think this is true for most programmers. You understand your
model and the manner in which you expect it to behave. On the fringes of your
program, you expect other code to behave properly or your code to account for
various conditions. In reality, it's doubtful that both you and the programmer
owning the other end of the code had exactly the same thought pattern.  Also
it's doubtful you understand all the variations in behavior in the other
programmers code.

To further complicate matters, you are not the same programmer you were
yesterday. Hopefully you're better. As a programmer you constantly learn new
patterns, better methods and discipline. So when you program against code
you've written, you're approaching it with a different mindset and hence you
take different paths. In short, you're programming against someone else's code
and assumptions.

For instance there was a time where I didn't actively use RAII in my code.
Now I base all my C++ classes around this pattern and use it everywhere.
These days I tend to assume my classes implement this pattern.  I've been
bitten a few times when using older code that pre-dated my use of RAII.

The best way to avoid making bad assumptions is to actively question them at
all times. Guarding against your assumptions can occur at several levels. Over
time, I've found the following methods to be the most effective:

**

### 1) Don't trust yourself

**

Be as paranoid about yourself as others.

**

### **2) Turn Assumptions into Compiler Errors**

**

This is most effective when coding in C++. Occasionally I run into a situation
where we find certain classes are invalid inputs to a template, function, etc
...  The best way to prevent using the type in the wrong context is to turn it
into a compiler error.  Typically this is accomplished with a combination of
macros and templates. It's not pretty, but catching an error at compile time
is the cheapest way.  You can't ship a bug that doesn't compile.

**

### 3) Unit Testing

**

I once heard an engineer say that "1 test is worth 1000 expert opinions." It
doesn't matter how good you are or how simple the code is; given enough time,
you will make mistakes. The most effective and lasting way to ensure that you
don't make mistakes is to test your code relentlessly.

The other great aspect is it allows you to freeze an assumption in time. The
point at which you write the code is the best time to catalog the intended
behaviors of your code. Adding a unit test will preserve and enforce it for
the perceivable future.  

### 4) Retail Contracts

Retail contracts are similar to debug asserts. The difference is that they run
in retail as well as debug builds. Generally speaking in retail it will cause
a crash and Watson dump.

I've debated the merits of such an approach many times. But the principal that
wins for me is "if it's wrong at debug time, it's wrong at retail time". It's
much easier to catch a problem sooner rather that later. This is especially
true for C++ where problems can behave unpredictably and result in "random"
failures. Crashing on a line which says Contract.ThrowIfNull() leaves little
doubt to where the failure came from. It doesn't necessarily make finding the
underlying cause easier but it's a start.

I've heard the argument that checks are non-performant and shouldn't be done
in retail code. Most retail checks resort down to "if(!ptr) throw". Yes, if
you put many,many of these checks into a hot path of your code base it can
cause a performance problem. In my experience it's very unlikely that this
will happen. And if it does show up on a profile, it's a simple matter to
switch them to a debug assert, or move the retail assert further down in the
stack and out of the hot path.

### 5) Debug Asserts

I find debug asserts are nice for verification that is to expensive to run in
retail. I don't mean this to include simple NULL checks but more deep
verification of various data sets.

**

### ***) Code Reviews**

**

I didn't put this into any specific order because this is highly dependent
upon the person reviewing your code. I feel the other listed points add a
consistent level of quality to your code.  Bad code reviewers offer little
help in guarding against yourself and hence do little for quality. Good code
reviewers offer good protection but it's a one time shot so I still would put
it between unit testing and retail contracts.

There are the few people who have an amazing talent for code reviews. They
will make even the most experience programmer come out feeling like an
incompetent novice. They are invaluable and even though they are able to shame
me at times I insist upon code reviews from them when writing a feature.


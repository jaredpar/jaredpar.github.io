---
layout: post
---
I'm struggling with an introduction line to this blog post so I'm just going to go for bluntness:?? Regular expressions are limited and it's important to understand these limitations. Ok, now that the premise is out of the way, lets go to a sample.

For a time in college I was a teaching assistant in a introduction to Compiler course [1]. Regex's played a large role in the class and inevitably a question or two would appear on a test and the final. My favorite question was the following

> Imagine the C block comment token (/* */) was allowed to be recursive. For example /* /* this is a comment */ */. Write a regex which will match all C comments.

We'd get loads of interesting answers but there is only one correct one. It's not possible.

Why' The keyword in this question is "recursive."?? I prefer to call it "counting" though. Regular expressions a class of Finite Automata (FA). One of the properties of FA is they cannot be asked to match anything that is recursive (aka has the equal number of items on left hand side and right hand side). They lack the sufficient state necessary to do so. To accurately match this a Context Free Grammar is required. Enough with the terminology though.

Critics: Wait, you think asking a trick question on a test is a good idea?

Answer: At first no. I didn't like this question when I encountered it as a student and it took me a precious 10 minutes to answer. I knew the answer right off the bat but I was hesitant to write it down. As a TA I liked this question slightly more. Namely because we drilled on this point from day 1 and most students would still miss the question [2].  

I didn't truly appreciate this question until I started working professionally. I often see people struggling to create a functioning regex for patterns that it cannot possibly work for. One of the first places I saw it was in a piece of code that QA was (naturally) having a field day with. I was brought it for a code review and after seeing the regex and the problem I pointed out that it wouldn't be possible. It took a few minutes but I was able to convince them a regex wouldn't work. Up until that point no one had considered there wasn't a regex solution, just that the one they had wasn't good enough. Days were wasted in this venture.

Part of being a good programmer is recognizing the strengths and weakness's of your tools. Most importantly though is knowing the limitations. It will save you hours and potentially days of wasted work.

As an exercise which of the following can a regex help with (answer at bottom under [3])?

  1. A C# string 
  2. A C# string literal 
  3. An XML element 
  4. An XML attribute 
  5. A file system path 
  6. A C/VB/C# math expression 
  7. Email address 
  8. Matching a valid regex 

As a side note, there are several regex engines out there that support the notion of recursion. These will allow you to match these types of patterns but are not technically regexs in the strictest since of the word. These are not strictly speaking regular expressions in computing theory but recursive extensions are quickly becoming a part of many libraries.  

In a future (hopefully soon) post I will explore the recursive extensions to the .Net regular expression language.

[1] It had various names CS2330 is the most infamous

[2] Even though we would go over it verbatim in class

[3] Regex will work for 1,2,4,5,7


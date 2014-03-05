---
layout: post
---
People love to chat about how to conduct a C++ interview on [newsgroups](http://stackoverflow.com/search?q=c%2B%2B+interview). Eventually these topics will shift into a discussion about what questions a candidate **must** know in order for them to get a hire from a particular interview.  Unfortunately these questions tend to be items like the following.

  1. What happens when you delete NULL?
  2. Explain how exceptions affect constructor initialization.
  3. Which constructors are called for the following: SomeType a = SomeType(b); 

Sure these questions are valid parts of the language and knowing them is a plus and demonstrates a deal of mastery over the language. But not knowing them should by no means by a deal breaker. The goal of an interview is to spot good developers who will become a contributing member of the team. Good developers are motivated and passionate problem solvers. These questions are testing little more than memorization. It's easy to memorize rules after the fact. It's much more difficult to teach problem solving skills.

The problem with questions like the above is that a developer could be both passionate and competent in C++ and never have come across these rules. C++ is an unbelievably huge language and can operate in many different ways where these type of situations simply don't come up. For instance, I've known several very good C++ developers that spent the majority of their time working with COM. COM prefers HRESULTs to Exceptions and hence they never used exceptions in C++. Once we introduced exceptions into the code base, it took about 30 minutes to explain the rules and we were done.

C++ interviews should focus on the qualities that make a good developer: problem solving and passion. Of course a language based interview should certainly focus on the foundations of C/C+. Items like pointers, stack vs.  heap and the basics of memory management. But don't hinge the deal on little items that can be quickly taught. Otherwise you'll end up turning away good developers.


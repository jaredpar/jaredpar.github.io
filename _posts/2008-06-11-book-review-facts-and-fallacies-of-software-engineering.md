---
layout: post
---
I finished reading [Facts and Fallacies of Software
Engineering](http://www.amazon.com/Facts-Fallacies-Software-Engineering-
Development/dp/0321117425) a few weeks ago.?? This is an excellent book and I
recommend it for anyone who's been in the industry for a few years.

Typically I don't enjoy books of this type because I feel they are too
preachy, written by people who aren't on the front lines and don't understand
the day to day problems a programmer will face or are just too long winded.
Neither appears to be the case here.

Mr Glass takes a very interesting approach to this book.?? In addition to
listing good resources for every fact/fallacy he also offers a small (albeit
less detailed) section on why people disbelieve in this particular item.

Top 3 facts which I think have the most value in my job

  * **Fact 36: Programmer-created, built-in debug code is an important supplement to testing tools. **The majority of bugs filed against code I own are not because of an invalid behavior.?? It's much more likely that QA will hit an ASSERT I added to the code base which fire before the behavior difference.?? What's encouraging is QA will often note: If I ignore the assert everything seems to work alright.?? Without a dev assert these bugs would have gone unnoticed until a much bigger problem hit.??
  * **Fact 43: Maintenance is a solution not a problem. ** Except for the end of a cycle, I constantly do maintenance work to parts of the code base.?? If it's broken, doesn't meet standards, uses bad resource management, etc fix it!?? Don't wait for the bug.??
  * **Fact 49: Errors tend to cluster. ** Good QA members know this and actively exploit it.?? Unfortunately it affects my job since I'm on the receiving end :)

Top 3 facts which I think more people need to take to heart

  * **Fact 6: New tools and techniques cause an initial loss of productivity/quality. **Anyone who reads my blog knows that I am a huge tool guy (see the PowerShell tag).?? Tools come with a cost though.?? As productive as PowerShell and my other bag of tools make me they all came with a price tag.?? One that has been paid over many times but the initial ramp up did cost time.??
  * **Fact 19: Modification of re-used code is particularly error prone.?? **In my experience the costs of this are typically underestimated.?? Mainly because the behavior depended on is not well understood.
  * **Fact 38: Rigorous inspections should not replace testing.?? **I heard an engineer say it best on the history channel "One test is worth one thousand expert opinions."?? Inspections mean nothing if they are not backed up by tests.?? Even if the inspectors get it right, without a regression test there is no way to guarantee it will stay that way for the future. 

Top 3 facts which most surprised me

  1. **Fact 3: Adding people to a late project makes it later**.?? I heard this long before I read the book but I wanted to call it out because I remember just how surprised I was the first time I heard it.
  2. **Fact 25: Missing requirements are the hardest requirement errors to fix.?? **Falls into the category of "haven't thought about that one but makes sense."??
  3. **Fact 30: COBOL is a very bad language, but all the others (for business applications) are so much worse**.?? This stems more than anything else from my complete lack of knowledge about COBOL.?? It's an often scorned language yet if it was so bad no one used it then no one would complain. 

Citation:

Glass, Robert L.?? Facts and Fallacies of Software Engineering. Pearson,
Education Inc, 2003


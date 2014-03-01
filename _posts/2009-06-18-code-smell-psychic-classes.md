---
layout: post
---
Psychic classes have the appearance of ignoring data provided to it in an
attempt to provide you with an answer they predict is better for the
situation.'? It's impossible to look at a the data provided to an instance of
the class and understand what queries on the object will return because it may
think of a better answer for you, or a better piece of data to look at.

This comes from an example I ran into about a month ago. I work on an IDE and
naturally deal with a lot of parse trees and tokens. Parsing everything all
the time is expensive so naturally the results are cached in various places
for performance reasons.

While debugging one such cache I noticed some strange behavior. The cache
wasn't returning the right tree for the input it was provided. So I decided
to dig into the code a bit.

This cache takes several different forms of input which has no common base
class or interface. What I noticed though is that when resetting the input of
the service, it would not clear the existing cache or the previous form of
input. Also because of the way the code loaded certain forms of input had
precedence over others. So even an explicit clear did not guarantee the
'correct' input was used.

The result is a service that reads well in code, but will not always act as
you expect it to. The service at times will seemingly ignore all input and
pick a source it thinks is better. Take the following code as an example

    
    
    pCache->SetSource(pSomeFile);


    ParseTree* pTree = pCache->GetTree();  

This code is very straight forward but is certainly not guaranteed to do what
it appears to do.

I like to think the service is predicting the results rather than calculating
them. Or better yet guessing the answer. From the perspective of a code
reviewer, that's what's happening.

Obviously I was curious about the reason for this and did a bit of research.
It's a rather old class so I had to contact people who'd been on the team
awhile back and dig through the history of the code base to understand what
the purpose of this behavior was. It turns out it was done to fix a few
impactful scenarios where an alternate source needed precedence over the
typical source. Other devs didn't fully understand the source semantics of
the service and wrote methods that caused bad interactions. Eventually it
evolved to it's current odd state.

Thanks to [Dustin](http://diditwith.net/) for coining the term 'psychic
classes'. Other ones we considered were

  * Jedi Mind Trick classes: Weak name
  * Weatherman: It's a prediction after all??

And yes, we fixed this issue :)


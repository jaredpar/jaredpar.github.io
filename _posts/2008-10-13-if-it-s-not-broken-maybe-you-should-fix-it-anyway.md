---
layout: post
---
I know this is goes against conventional wisdom but it's something I believe
in.?? Every sufficiently large project has that section of code nobody wants to
go near.?? The mere mention of it causes people to leave the room.?? It usually
has a couple of properties

  1. Old and Stagnant 
  2. Critical or important routine 
  3. Fragile 
  4. Written by a developer who doesn't work there anymore 
  5. Undocumented 
  6. Untested 
  7. Poorly understood 

But it works and usually has for several releases.?? By conventional wisdom it
is considered "unbroken" and not worthy of changing.

I disagree.?? Very often I find towards the end of the cycle more and more bugs
start popping up in this code.?? It's a pattern I've seen in many groups across
releases.?? These bugs are extremely expensive to fix because they are a) at
the end of the cycle and b) being make in a piece of code that no one
understands.?? Since it's not broken nobody bothered with the code and hence it
stayed poorly understood (and likely just as untested).?? The bugs are doubly
worse because no one wants to go near that code for fear of breaking the
world.

Why let this code hang around in it's current state??? It's bad and no one
understands why.?? It's a constant source of pain late in the cycle and often
in the middle.

I prefer to take a more proactive approach; fix it.

At the end of a product cycle I like to identify these pieces of code and
attack them in-between releases.?? This is a relatively safe point in the
release cycle to change poorly understood code.?? There is an entire release
cycle ahead to catch the bugs introduced (and there will be some).

I don't break this code without thought.?? I prefer to take a pragmatic
approach to the code in the following steps.

  * Attempt to understand the intent of the code (easier said than done).?? I contact the original author if possible 
  * Poll the more senior developers on their understanding of what the code does 
  * Design a new architecture if needed 
  * Design a test plan (this is the absolute most important step.?? Why fix this if you don't bother testing it?) 
  * Make the change 

I've done this, or overseen someone else, on several pieces of code over the
last few years.?? Thus far it's been a very big success.


---
layout: post
---
While investigating our locking infrastructure a few days ago I ran across an
odd comment. I was looking at a particular usage of a lock and the comment
said that "Using lock type X because we must pump messages here."?? Contrarily
the lock type being used most definitely did not allow message pumping.

After a quick history search on the code base I was able to track down the
developer responsible for the discrepancy. He merely forgot to update the
comment when making the change. However he was able to explain the history
behind the comment and the switching of the locking type.

I've heard people argue in the past that they didn't comment code because
comments get out of date and lead developers in the wrong direction. They
might do it correctly but they didn't trust the next guy. Then the comment
would be wrong and useless for the next developer.

I think this is a example of why that mentality is wrong.

  1. Even though it was currently wrong it was historically accurate
  2. The commented add good insight into the choice of locking mechanism
  3. It added a bit of detail into the historical architecture of the code base.
  4. It was a heck of a lot better than staring at a comment-less field that appeared to exist for no reason.

I'm not arguing that comments which are flat out wrong at the time they are
authored are a valuable resource. Yet not commenting because you don't
"trust" the next guy is equally wrong.


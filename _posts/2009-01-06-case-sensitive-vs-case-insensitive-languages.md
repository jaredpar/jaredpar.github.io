---
layout: post
---
Just had a random thought while I was looking at some code today. It's yet another argument in the case sensitive vs. case insensitive language battle.

Do you really want this to be able to compile?

    
``` csharp
class C1 {
  int M1;
  int m1;
}
```

Yes it's an abuse and should absolutely be caught in a code review. But at the same time, experience has taught me that if an evil thing can be done with a language, someone will do it.

And yes, sadly I've seen code like this before.


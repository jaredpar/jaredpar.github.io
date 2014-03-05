---
layout: post
---
One of the parts of a Tuple implementation for [RantPack](http://code.msdn.microsoft.com/RantPack) I struggled the most with was naming. I tend to struggle with names quite a bit and there's really no reason for it. It's a combination of pickiness and ... well there's really no good reason. Pieces which can bother me range from

  1. Don't like the way it types. If I can't type something easily it drives me nuts and I secretly desire to change it to a word that is easier to type. I have sadly spent a large amount of time on [www.thesaurus.com](http://www.thesaurus.com) looking for better words to type.
  2. Looks funny. No real solid criteria here, just what I don't like. Words sometimes look good the first time you type them but over time lose their appeal
  3. Doesn't match conventions. Ah, now we're onto solid reasons. Names should match conventions.
  4. Name is ambiguous. If the name doesn't give a clear intention of the operation I do my best to change it.
  5. FxCop violation. This bothers me less than others but if FxCop doesn't like it I think a bit harder about naming it. 

Now comes Tuples. Many implementations of tuples don't even have names but instead rely on language constructs such as pattern matching to access the values. That's not really the DotNet way of doing things though so I chose to give Tuple values names.

Originally I chose A for item 0, B for item 1, etc ... This made sense at the time because it kept the syntax short. However I've grown to dislike this naming convention. Primarily because it violates #3 and #4 above. While A-E is perfectly clear for me I've talked with others who this confuses.

In addition, to keep the nameless syntax option I provided an indexer property. So values are available with a 0 based index. Since several languages expose this with the name "Item", there are now really two names for a value. For example the first value is both tuple.A and tuple.Item[0].

After some thought I decided to name the values Item0->Item4 depending on the size of the tuple.


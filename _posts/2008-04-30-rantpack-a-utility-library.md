---
layout: post
---
I often post code examples, samples and snippets on this blog.  Many of these
samples are a part of a utility library I've been writing and maintaining for
many years now.  Essentially since I got involved in DotNet programming.

I write a lot of code for internal apps, demos and hobby projects.  Having a
utility library to tote around with me greatly increases my impact in a
project because it gives me a place to put common code that I would otherwise
have to repeatedly cut and paste into projects.

Whenever I work on something I think the community at large would benefit from
I try to blog about it.  Unfortunately for the more complex samples blogging
is not always easy.  Complex structures don't really fit on a blog and often
utilities depend on utilities and it forces users to cut and paste between
multiple blog entries.  Not good.

Now with [http://code.msdn.com](http://code.msdn.com/) I have a forum to fully
share the items I've been working on.  This is the perfect place to share code
for the community and helps avoid the messiness of cutting and pasting blog
posts.  As such I've released my Library,
[RantPack](http://code.msdn.microsoft.com/RantPack), on Code Gallery.  This
includes both binaries and sources and is covered under the [Microsoft Public
License](http://code.msdn.microsoft.com/RantPack/Project/License.aspx).

RantPack is available at <http://code.msdn.microsoft.com/RantPack>

A couple of notes on the sample. This is mainly for education and sharing
purposes.  The goal of this library is to make developing software faster and
more reliable.  It includes, but is not limited to

  * Functional Programming Patterns
    * Tuples
    * Immutable/Persistent collections
  * Threading 
    * Futures
    * Active Objects
    * Various other primitives
  * General Patterns
  * General Utilities

Another item you will find browsing the sources are tests.  Lots and lots of
tests.  At the time of this writing there are around 400 some odd unit tests
on the library.  There is nothing more frustrating than a utility library that
doesn't work.  As such I rigorously test the code I write.

Although I performance test much of my code and it performs great in the
applications I use it for I'm sure there are a few cases I missed.  Please
feel free to point this out to me and I'll look into them.

Why the name RantPack?  My blog is Rantings of a programmer and it's a pack of
code :)


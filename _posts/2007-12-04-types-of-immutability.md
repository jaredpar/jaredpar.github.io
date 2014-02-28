---
layout: post
---
By definition, an [immutable
object](http://en.wikipedia.org/wiki/Immutable_object) in computer science is
one that is not able to change.  Parallel coding is becoming more necessary as
the number of cores in a processor are increasing but not the overall speed.
As such immutability is will become more important because it is an important
asset of multithreaded programming.  Immutable objects are inherently thread
safe.

Like other categorizations in computer science, there are degrees of being
unable to change.  This post is an attempt to outline and categorize several
of the variations.

Note: these are not standard categorizations.  They are merely my attempt to
name several of the scenarios you can encounter with immutable objects.

**Immutable**

Object itself has no fields that can change.  In addition all of it's fields
are also Immutable and thus cannot be changed.  This object is carved in stone
and short of process corruption, it will be the same in every way.

For primitives excluding string this can be ensured by making them read only
(.initonly in IL).  For reference types the field must be read only and the
type must also meet the Immutable guidelines.

Types with meet the Immutable guarantee are inherently thread safe.  They are
not subject to race conditions because they cannot be changed and thus viewed
differently between threads.

**Shallow Immutable**

The direct contents of this object must be immutable in the sense that they
cannot be changed to point to another object.  However there is no guarantee
that all of the fields are themselves immutable.

All of the fields in the object must be read only.  For primitive values this
is enough to guarantee them meeting the Immutable guidelines and hence Shallow
Immutable.  For reference types this will ensure they will point to the same
object thus doing all that is needed to meet the Shallow Immutable Guarantee.

Types with this guarantee are thread safe to a degree.  They are thread safe
as long as you are accessing the fields with meet the Immutable guarantee.
You can also access the references which are read only as long as you do not
call any instance methods.  For instance a Null check is thread safe.

**Shallow Safe Immutable**

Slightly stronger guarantee than Shallow Immutable.  For all fields that are
read only but not immutable, the type must be thread safe.

Types which meet this guarantee are thread safe also to a degree.  They are as
thread safe as the fields which are guaranteed to be thread safe.


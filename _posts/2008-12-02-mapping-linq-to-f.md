---
layout: post
---
In my projects with F#, I often find that I know exactly what type of sequence
transformation I want to run, yet I spend all of my time trying to find it!!!
The problem is I???m used to query comprehensions in LINQ terminology.?? Select,
Where and SelectMany are so ingrained into my programming they are practically
done through muscle memory.

Unfortunately there is a disconnect between the naming convention used in LINQ
and the ones used in F#.?? Some of the names are more intuitive than others.
I???ve now spent enough time digging through Seq.fs that it???s time to draw up a
table that maps various LINQ functions to their equivalent method in F#.

If nothing else, it will be a good table for me to come back to.?? Below is a
list of many methods in [Enumerable](http://msdn.microsoft.com/en-
us/library/system.linq.enumerable_methods.aspx), mapped to the equivalent
function in F#???s seq

  * Aggregate ???> fold
  * All ???> for_all
  * Any ???> exists
  * Average ???> average
  * Cast ???> cast
  * Count ???> length
  * Distinct ???> distinct
  * ElementAt ???> nth
  * Empty ???> empty
  * First ???> hd
  * GroupBy ???> group_by
  * Max ???> max
  * Min ???> min
  * OrderBy ???> sort_by
  * Select ???> map, mapi
  * SelectMany ???> concat, map_concat
  * SequenceEqual ???> compare
  * Skip ???> skip
  * SkipWhile ???> skip_while
  * Sum ???> sum
  * Where ???> filter

Below are the functions for which an equivalent was not found (or was quite
simply overlooked).?? Most of these can be added with a combination of other
simple transformations.

  * DefaultIfEmpty
  * Except
  * FirstOrDefault
  * GroupJoin
  * Intersect
  * Join
  * Last
  * LastOrDefault
  * LongCount
  * OfType
  * Reverse
  * Single
  * SingleOrDefault
  * Union


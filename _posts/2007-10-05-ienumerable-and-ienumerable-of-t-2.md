---
layout: post
---
Quick follow up to my earlier
[post](http://blogs.msdn.com/jaredpar/archive/2007/10/04/ienumerable-and-
ienumerable-of-t.aspx).  Fixing this issue in C# is even easier because of the
existence of iterators.

    
    
            public static IEnumerable<object> Shim(System.Collections.IEnumerable enumerable)


            {


                foreach (var cur in enumerable)


                {


                    yield return cur;


                }


            }


    


---
layout: post
---
The PowerShell pipeline, is fairly similar to C#/VB???s LINQ.?? Both filter a
group of elements through a series of transformations which produce a new
series of elements.?? The devil is in the details of course but I???ll get to
that in a future post.

When using PowerShell I constantly find myself wanting to use various LINQ
expressions on a pipeline.?? Unfortunately, many LINQ expressions have no
built-in equivalent in PowerShell.?? Most are fairly straightforward to write
but a few are a bit trickier.?? In either case, there???s no reason for people
needing to figure them out twice.?? So I???ll be starting a series on LINQ
expressions in PowerShell.

Also, my posts are getting a bit long winded as of late.?? This will be a good
oppuritunity to get some shorter posts up.

Today's entry is the equivalent of [Enumerable.Skip](http://msdn.microsoft.com
/en-us/library/bb358985.aspx).?? The operation takes a count and skips ???count???
elements in the enumeration.?? For PowerShell, it???s the equivalent of skipping
???count??? elements in the pipeline.

    
    
    #============================================================================


    # Skip the specified number of items


    #============================================================================


    function Skip-Count() {


        param ( $count = $(throw "Need a count") )


        begin { 


            $i = 0


        }


        process {


            if ( $i -ge $count ) { 


                $_


            }


            $i += 1


        }


        end {}


    }

Example:

    
    
    PS:) 1..10 | skip-count 5


    6


    7


    8


    9


    10


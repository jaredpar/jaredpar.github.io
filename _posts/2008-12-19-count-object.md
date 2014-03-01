---
layout: post
---
With all of the great built-in commands for processing pipelines the absence
of a good command to count the number of elements in a pipeline seems to stand
out. The best built-in way to count the number of objects in a pipeline is to
convert the value into an array and then take the length. For instance take
the following script which looks for the word 'test' in all of the .ps1
scripts in or below the current directory

    
    
    $PS> gci 're 'in *.ps1 | %{ ss test $_.FullName } 

Now if i want to count that i must convert it into an array and then take the
length. Simple enough right?

    
    
    $PS> @(gci 're 'in *.ps1 | %{ ss test $_.FullName } ).Length

This approach works but has a couple of issues associated with it.

The first is a bit whiney I'll admit. I often use powershell scripts in an
incremental fashion. I write a search/expression, decide it includes to much
data and refine it. With any decent command shell this is a pretty simple
operation, hit up and add another element to the powershell pipeline and
you're in business.

The array method of counting though requires me to add data on both sides of
the expression. So it's a choice of holding down left and waiting for the
cursor to get to the right position or leaving the keyboard and opting for the
mouse. I don't like either solution because it takes too long or gets my hand
off of the keyboard. Did I mention this was whiney?

The second is that it forces you to allocate a contiguous block of memory to
examine the?? length. While this is usually not a big concern, it can cause
noticeable performance issues if you are processing a lot of data. This is
especially true if the length is taken on inner expressions.

A better solution is using a filter to count the elements. Filters integrate
into the powershell pipeline and process data a single element at a time.
This solves both problems above. The first is that it will smoothly integrate
onto the end of an existing pipeline. Also because it is a filter it
processes each element individually preventing a huge array allocation.

    
    
    function Count-Object() {


        begin {


            $count = 0


        }


        process {


            $count += 1


        }


        end {


            $count


        }


    }

Now lets get back to the original problem.

    
    
    $PS> gci 're 'in *.ps1 | %{ ss test $_.FullName } | count-object 

Much nicer


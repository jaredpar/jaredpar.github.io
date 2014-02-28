---
layout: post
---
Next up in the PowerShell LINQ series is [SkipWhile](http://msdn.microsoft.com
/en-us/library/bb549075.aspx).?? This LINQ function takes an enumerable
instance and a predicate.?? The function will skip the elements in the
enumerable while the predicate is true.?? The argument to the predicate is the
current value of the enumerable.

The LINQ version takes a predicate in the form of a
[Func<T,TResult>](http://msdn.microsoft.com/en-us/library/bb549151.aspx).?? The
PowerShell equivalent of a delegate is a script block.?? Unlike a .Net
delegate, there is no way to type the Skip-While function to accept a
particular number or type of arguments.?? The contract with the caller will be
implicit.

Other than the strict typing, the function will match the contract for the
LINQ version of SkipWhile.

    
    
    #============================================================================


    # Skip while the condition is true


    #============================================================================


    function Skip-While() {


        param ( [scriptblock]$pred = $(throw "Need a predicate") )


        begin {


            $skip = $true


        }


        process {


            if ( $skip ) {


                $skip = & $pred $_


            }


    


            if ( -not $skip ) {


                $_


            }


        }


        end {}


    }

Example Usage:

    
    
    PS) 1..10 | Skip-While { $args[0] -lt 6 }


    6


    7


    8


    9


    10


    PS)


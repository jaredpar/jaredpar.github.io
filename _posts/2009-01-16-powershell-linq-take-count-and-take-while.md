---
layout: post
---
The Take pair of functions are very similar to the [Skip functions](http://blogs.msdn.com/jaredpar/archive/2009/01/14/powershell-linq-skip-while.aspx). The Take expression does essentially the opposite of the Skip functions. Skip is useful for getting elements further down the pipeline. Take is used for getting elements from the start of the pipeline.

    
    #============================================================================
    # Take count elements fro the pipeline 
    #============================================================================
    function Take-Count() {
        param ( [int]$count = $(throw "Need a count") )
        begin { 
            $total = 0;
        }
        process { 
            if ( $total -lt $count ) {
                $_
            }
            $total += 1
        }
    }
    
    #============================================================================
    # Take elements from the pipeline while the predicate is true
    #============================================================================
    function Take-While() {
        param ( [scriptblock]$pred = $(throw "Need a predicate") )
        begin {
            $take = $true
        }
        process {
            if ( $take ) {
                $take = & $pred $_
                if ( $take ) {
                    $_
                }
            }
        }
    }

Example

    PS) 1..10 | take-count 5
    1
    2
    3
    4
    5
    PS) 1..10 | take-while {$args[0] -lt 6}
    1
    2
    3
    4
    5
    PS)


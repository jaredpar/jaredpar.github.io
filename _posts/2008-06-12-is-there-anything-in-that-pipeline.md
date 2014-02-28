---
layout: post
---
One operation I frequently perform is use a powershell pipeline to filter out
a large set of data.  Typically I don't care what is in the result but rather
is there actually anything left in the pipeline.  I can't find a good
powershell built-in to perform this task so I use the following filter.

function Test-Any() {  
    begin {  
        $any = $false  
    }  
    process {  
        $any = $true  
    }  
    end {  
        $any  
    }  
}

Now I can easily write

$any = Some-Command | ?{ Some-Condition } | test-any


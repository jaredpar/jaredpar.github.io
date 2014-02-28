---
layout: post
---
I like my scripts to be readable and terse.  They're scripts after all and I
want to get the most done with the least amount of code.  There's a lot to be
said for having a readable script but I only value that when I intend to keep
the script around for awhile.

PowerShell does not have a ternary operator and that often frustrates me as I
end up writing lots of verbose code.

Once again, fix it by introducing a small function into my profile.  Not quite
a true ternary operator because it evaluates both of the result arguments.
But it does the trick for most situations.

function Get-Ternary()  
{  
    param ( [bool]$condition = $(throw "Need a conditional"),  
            $valueTrue = $(throw "Need a value for the true condition"),  
            $valueFalse = $(throw "Need a value for the false condition") )  
    if ( $condition )  
    {  
        return $valueTrue  
    }  
    else  
    {  
        return $valueFalse  
    }  
}

Now I can type

PS> Get-Ternary $cond 1 42


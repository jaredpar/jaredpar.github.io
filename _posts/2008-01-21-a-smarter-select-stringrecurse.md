---
layout: post
---
Previously I blogged about a [recursive select-string function.](http://blogs.msdn.com/jaredpar/archive/2007/10/08/select-stringrecurse.aspx)  Recently I've extended it a bit.  I found the function to be very useful but when I encountered problems searching large directories that contained binary files.  Namely searching them usually returned a result of sorts and printing out the contents of a binary file caused my console to beep in a rather annoying fashion.  To fix this I added a new parameter that will perform a slightly smarter search by filtering out binary files.

    function Select-StringRecurse()  
    {  
        param ( [string]$text = $(throw "Need text to search for"),  
                [string[]]$include = "*",  
                [switch]$smart = $false) 

        $smartRegex = "^\\.(lib|exe|obj|bin|tlb|pdb)$"  
        gci -re -in $include |   
            ? { -not $_.PSIsContainer } |   
            ? { (-not ($smart)) -or (-not ($_.Extension -match $smartRegex)) } |  
            % { write-debug "Considering: $($_.FullName)"; ss $text $_.FullName }  
    }  


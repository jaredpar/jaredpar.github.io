---
layout: post
---
When you need to search for text in a file, select-string is your best friend.  It has most of the functionality of old unix grep. In addition it does full regular expression support.

The only downside is that it will only run on files in the current directory.  Unlike get-childitem, it has no recurse parameter. In addition, I'm lazy and I don't like typing out select-string every time. I have the following definitions in my Profile to make this easier.

    function Select-StringRecurse()  
    {  
    '' param ( $text = $(throw "Need text to search for"),  
    '''''''? $filter = "*" )  
    '' gci -re -in $filter | ? { -not $_.PSIsContainer } | % { ss $text $_ }  
    }

    set-alias ss'' select-string  
    set-alias ssr'? Select-StringRecurse


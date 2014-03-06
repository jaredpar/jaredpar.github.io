---
layout: post
---
[Tuples](http://en.wikipedia.org/wiki/Tuple) in computer science are usually light weight record objects with simple name value pairs.  In scripting languages it is very handy to create them on the fly.  For quite some time I was using associative arrays in PowerShell to do just that.

    PS>$a = @{Name="MyName";Value="MyValue"}

It has essentially everything you would need from a tuple inside of a scripting language.  The more and more I use PowerShell though I've found that this is not always a good idea.  It comes back to PowerShell pipelining.  Whenever you pass a collection to a pipeline PowerShell will unroll the collection and pass the individual items.

Under the hood, an associative array is a System.Hashtable.  As a result it is a collection of name value pairs.  Hence when you pass this tuple through a pipeline, it is torn apart and each element of the tuple is passed as a separate object.  
    
    PS>$a = @{Name1="Value1";Name2="Value2"}
    PS>$a
    
    Name                           Value
    ----                           -----
    Name2                          Value2
    Name1                          Value1

Hence I've now taken a new route.  Create an actual tuple :)

    function New-Tuple()  
    {  
        param ( [object[]]$list= $(throw "Please specify the list of names and values") ) 

        $tuple = new-object psobject  
        for ( $i= 0 ; $i -lt $list.Length; $i = $i+2)  
        {  
            $name = [string]($list[$i])  
            $value = $list[$i+1]  
            $tuple | add-member NoteProperty $name $value  
        } 

        return $tuple  
    }

    PS>$a = New Tuple Name,1,Value,2

The result can now be passed around pipelines as a single entity.


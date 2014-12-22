---
layout: post
---
Quick script that will allow you to pipe each char in a String into the PowerShell pipeline.

``` powershell
function PipeStringChar()
{
    param ( [string]$toPipe )
    for ( $i = 0; $i -lt $toPipe.Length; $i++ )
    {
        write-output $toPipe[$i]
    }
}
```

Alternatively you can do this by using the ToCharArray method.  However this will create a new array in memory and if you have a large string that will be fairly expensive.  The above method will do it the PowerShell way.  

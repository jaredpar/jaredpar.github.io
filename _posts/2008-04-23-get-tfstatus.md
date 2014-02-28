---
layout: post
---
Been far too long since I blogged about a new PowerShell script.  This is not
to say I've stopped using PowerShell, more that I've been too busy playing
with other tools to spend a significant amount of time updating my scripts.

This is a simple, yet straight forward script.  The intent is to make the "tf
status" command easier to use from PowerShell.  I often want to do some last
second verification on files I've altered.  The default output is not easy to
one time parse so a script is handy.

function Get-TfStatus() {  
    param ( [string]$path= "." ,  
            [switch]$recursive = $false ) 

    $args = ""  
    if ( $recursive ) {  
        $args = "/r"  
    }  
    $output = [string[]](& tf status $path $args) 

    # First two lines are junk so skip past it  
    for ( $i = 2; $i -lt $output.Length; $i++ ) {  
        $name,$edit,$path = $output[$i].Split(" ", [StringSplitOptions]"RemoveEmptyEntries")  
        if ( $path -and (test-path $path) ) {  
            new-tuple "FileName",$name,"Change",$edit,"FilePath",$path  
        }  
    }  
}

$PS> get-tfstatus -r

FileName                   Change                     FilePath  
\--------                   \------                     \--------  
File1.cpp               edit                       E:\dd\sourcepath\src\v...  
File2.cpp               edit                       E:\dd\sourcepath\src\v...  
File3.h                  edit                       E:\dd\sourcepath\src\v...


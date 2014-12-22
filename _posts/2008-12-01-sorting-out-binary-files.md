---
layout: post
---
I constantly get tripped up in my powershell scripts/commands because I run them against a binary file. In particular when I'm searching through a directory structure looking for a particular string or regex. I've found the simplest way to avoid this problem is to use a simple regex check to filter out the known binary files.

``` powershell
#==============================================================================
# Is this an extension for a binary file type? 
#==============================================================================
function Is-BinaryExtension() {
    param ( [string]$extension = $(throw "Need an extension" ) ) 

    $binRegex= "^(\.)?(lib|exe|obj|bin|tlb|pdb|doc|ncb|dll|pch)$"
    return $extension -match $binRegex
}

function Is-BinaryFileName() { 
    param ( [string]$fileName = $(throw "Need a file Name") )
    return (Is-BinaryExtension [IO.Path]::GetExtension($fileName))
}
```

Now running a recursive search on a directory structure is quick and easy

``` vbnet
function Select-StringRecurse() {
    param ( [string]$text = $(throw "Need text to search for"),
            [string[]]$include = "*",
            [switch]$all= $false)

    gci -re -in $include | 
        ? { -not $_.PSIsContainer } | 
        ? { ($all) -or (-not (Is-BinaryExtension $_.Extension)) } |
        % { write-debug "Considering: $($_.FullName)"; ss $text $_.FullName }
}   
```


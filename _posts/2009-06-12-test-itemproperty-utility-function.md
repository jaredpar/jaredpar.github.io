---
layout: post
---
I was playing around in the registry the other day and found the PowerShell
API lacking in a key area. There does not appear to be a good way to detect
the presence of a Registry Name/Value pair. All of the operations such as
New, Delete, Rename are based off of the program knowing the presence or
absence of the key before hand. This lacks symmetry with the rest of the APIs
which have a test style function.

    
    
    PS> test-path "some\file\path\data.txt"


    True

I took a few minutes and sketched out a basic Test-ItempProperty function. It
utilizes the Get-ItemProperty function and suppresses the rather loud red font
error message via the 'ErrorAction parameter (standard on all CmdLets).

    
    
    function Test-ItemProperty() {


        param ( [string]$path = $(throw "Need a path"),


                [string]$name = $(throw "Need a name") )


    


        $temp = $null


        $temp = Get-ItemProperty -path $path -name $name -errorAction SilentlyContinue


        return $temp -ne $null


    }

Now I can finish up my happy scripting for the night

    
    
    PS> test-path . IsItScriptingTime


    True


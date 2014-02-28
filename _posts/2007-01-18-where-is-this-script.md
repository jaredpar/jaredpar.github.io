---
layout: post
---
Scripts often need to dynamically find out what directory they are executed
from.  In CMD scripts this is done by %~dp0.  For powershell the following
will do the trick.

  split-path -parent $MyInvocation.MyCommand.Definition

 When this is run anywhere in the script body (not a function within the
script) it will return the directory currently holding the running script.  If
you execution this from a function within a script though, it will print out
the body of the function.  If you need to know the directory of the script
inside the body of the script, store it in script level variable.

  $script:mypath = $MyInvocation.MyCommand.Definition

  function printScriptPath() { return $script:mypath; }




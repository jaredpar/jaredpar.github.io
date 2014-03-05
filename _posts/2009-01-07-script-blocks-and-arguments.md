---
layout: post
---
Script blocks are a powershell construct for storing an expression or group of statements inside an expression. It's the equivalent of a C#/F#/VB Lamba expression. Recently I needed to use a script block but found I had forgotten how to read passed parameters inside the script block.

Forgetting how to use a feature is typically not a blog worthy post. However this is at least the fourth time I've run into this situation. Hopefully blogging about it will help me remember. Or at least give me a quick search result from google.

Normally I go through a few steps when I run into an issue with PowerShell.

  1. Use the built-in ''get-help' command 
  2. Search through my library of scripts for previous usages of a pattern 
  3. Google for a solution 
  4. Experiment within the shell 

Script blocks are one of the problems that seem to hang around until step #4.

Getting to the documentation is usually a chore. It is filed under about_script_block. This is contradicts the built-in type name [scriptblock].  Usually it takes me a few tries to get the documentation up. The internal documentation is very weak for a script block. It provides little more than a basic sample.

My internal library scripts use script blocks pretty heavily but due to the incredibly terse syntax, searching for them is usually fruitless. After all, they just need a brace pair which is hardly unique within a powershell script.  

This leads to step #3. I am by no means a google ninja. In fact I am often shamed by my non-technically oriented wife in getting relevant google results.  Occasionally, I've even resorted to asking her to give me search words.  Shameful, yes.

Given that with such common places words as 'script', 'block' and 'argument', my chances of getting a good result are pretty slim. Recently things are brightening up as more people are blogging about powershell. But it's still hard to get a good article on the finer points of a script block.

Now we're down to experimentation. Most scripting entry points in PowerShell have access to the built-in $args variable. This is true for both functions, scripts and filters.

    PS> function test() { $args.Count }  
    PS> test 42  
    1  
    PS> test 42 "astring"  
    2

Perhaps the same is true for a script block.

    PS> $a = { $args.Count }  
    PS> & $a 42  
    1  
    PS> & $a 42 "astring"  
    2  
    PS>

Success!!! Maybe I'll remember next time.


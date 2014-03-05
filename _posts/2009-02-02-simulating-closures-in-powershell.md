---
layout: post
---
[Previously](http://blogs.msdn.com/jaredpar/archive/2009/01/08/script-blocks-and-closures-or-lack-there-of.aspx) I blogged about PowerShell's lack of closure support within a script block. This presents a significant hurdle in developing a LINQ like DSL for powershell which I've been working on. Imagine the following syntax
    
    $a = from it in $source where {$it -gt 5 }

This would be the rough equivalent of the following C# code
    
{% highlight csharp %}
var a = from it in source where it > 5;
{% endhighlight %}

In C# this code works because the where clause 'it > 5' is converted to a lambda expression under the hood. The variable it is captured in the lambda expression via a closure. In order to get similar functionality out of powershell, the value $it must be resolvable when the 'where' scriptblock is executed.

Luckily Powershell is incredibly flexible. When a script block executes it will attempt to resolve any variables by looking through the various scopes.  The first scope is that of the script block, and then the local scope of the code in which the script block is executed. Using new-variable, we can create variables which match the name the script block is looking for and simulate a closure.

    PS) $sb = { write-host $it }
    PS) & $sb
    
    PS) new-variable "it" 42 -scope local
    PS) & $sb
    42

Success!!! Now all we need to do is generalize this behavior by creating a function: Run-Scriptblock. It takes two arguments

  1. The scriptblock to execute 
  2. A list of name/value pairs. Each one represents a variable that must be available for the execution of the scriptblock 

Code:

    #============================================================================
    # Runs a script block.  The $list parameter must be a list of string, value
    # combinations.  The script block will be executed with variables of the 
    # specified name and value in scope
    #============================================================================
    function Run-Scriptblock() {
        param ( [scriptblock] $sb = $(throw "Need a script block"), 
                [object[]]$list= $(throw "Please specify the list of names and values") )
    
        for ( $i = 0; $i -lt $list.Length; $i = $i+2 ) {
            $name = [string]($list[$i])
            $value = $list[$i+1]
            new-variable -name $name -value $value -scope "local"
        }
    
        & $sb
    }

Example Usage:

    PS) $sb = { write-host $it }
    PS) run-scriptblock $sb "it",42
    42
    PS) $it

Now we have the method by which to execute a 'where' clause. Next time we'll look at actually defining a LINQ DSL in powershell.


Part 1 of the series outlined the basic structure of the tuple.  This entry will produce a PowerShell script that will generate N tuple classes containing 1-N name value pairs. 

The first step is to get a few script variables defined.  All of the names used in the tuples will be lower and upper case single characters tied to a specific index.  To make the script a bit shorter we will define indexable arrays up front for the letters.   We'll also grad the tuple count.

$script:tupleCount = [int]$args[0] 
$script:lowerList = 0..25 | %{ [char]([int][char]'a'+$_) } 
$script:upperList = 0..25 | %{ [char]([int][char]'A'+$_) }

All of the functions in this script will output an array of strings into the PowerShell pipeline.  One of the neat/confusing features of PowerShell is that values that are not directly used in a function are passed onto the pipeline.  This will conveniently allow us to type in literal code and hopefully increase readability. 

Now for the function that generates a property.  The tuples will be immutable by default as such we will generate private read only fields and simple getters. 

It would also be just as plausible to skip the property here and instead produce a read only public field.  Later on we will be altering the tuples to be used in a generic fashion through interfaces.  Interfaces cannot define fields and instead we will need properties. 

{% highlight powershell %}
{% raw %} 
function script:Gen-Property 
{ 
    param ( [int] $index  = $(throw "Need an index") ) 
@" 
    private readonly T{0} m_{1}; 
    public T{0} {0} {{ get {{ return m_{1}; }} }}

"@ -f $upperList[$index],$lowerList[$index] 
}
{% endraw %}
{% endhighlight %}

Next up we need to define a constructor.  All of the fields in the tuple are read only so we must define a constructor for the consumer (otherwise the tuples would be useless). 

Generating the parameter list string would be tedious in most languages but PowerShell makes it a snap.  When converting an array of strings into a single string the individual strings will be combined with the value of the *** $OFS variable (default is space).  We can switch this to a comma and provide a quick pipeline for the parameter list. 

{% highlight powershell %}
function script:Gen-Constructor 
{ 
    param ( [int] $count = $(throw "Need a count") ) 
    $OFS = ',' 
    $list = [string](0..$($count-1) | %{ "T{0} {1}" -f $upperList[$_],$lowerList[$_] }) 
    "public Tuple($list) {" 
    0..($count-1) | %{ "m_{0} = {0};" -f $lowerList[$_] } 
    "}" 
}
{% endhighlight %}

Now that we have the basics we can generate the class.  We'll use the same $OFS trick to generate the generic argument list here.

{% highlight powershell %}
function script:Get-Tuple 
{ 
    param ( [int] $count ) 
    $OFS = ',' 
    $gen = "<" + [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"    

    "public sealed class Tuple$gen {" 
    0..($count-1) | %{ Gen-Property $_ } 
    Gen-Constructor $count 
    "}" 
}
{% endhighlight %}

Now all that's left is processing the arguments

{% highlight powershell %}
[string](0..($tupleCount-1) | %{ Get-Tuple ($_+1) })
{% endhighlight %}

Next step is to generate code that is more type inference friendly. 

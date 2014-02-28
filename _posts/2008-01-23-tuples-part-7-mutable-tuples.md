Part 6 left us with comparable tuples.  At this point, the Tuple class is functionally complete.  There will be a little more done with the debugability and overall fit into larger projects.  But otherwise it is sound. 

Now the focus shifts to generating mutable tuples.  Immutability is nice for threading, memoization, etc ...  However it's not always practical to use immutable objects.  Often an algorithm does not benefit from immutability and lends itself to a more mutable type. 

Mutable tuples behave like a Tuple in every other way except that they're ... mutable.  This includes implementing interfaces as well as inheritance structure. 

{% highlight csharp %}
public sealed class MutableTuple<TA, TB> : 
    ITuple<TA, TB>, 
    IEquatable<MutableTuple<TA, TB>>, 
    IComparable<MutableTuple<TA, TB>>, 
    IComparable
{
{% endhighlight %}

As such the script already used will be sufficient to generate mutable classes in addition to the ones its already doing.  The majority of the code difference is just in the naming of the classes.  The only functional differences exist in the properties and indexer.  Both of these add a setter method.  Below is the modified code for generating the property and indexer. 

{% highlight powershell %}
function script:Gen-TupleAccess 
{ 
    param ( [int] $count = $(throw "Need a count"), [bool]$mutable ) 
    "public int Count { get { return $count; } }" 
    "public object this[int index] { get { switch (index){ " 
    0..($count-1) | %{ "case $($_): return m_$($lowerList[$_]);" } 
    "default: throw new InvalidOperationException(""Bad Index"");" 
    "} }"

    if ( $mutable ) 
    { 
        "set { switch (index) {" 
        0..($count-1) | %{ "case $($_): m_$($lowerList[$_]) = (T$($upperList[$_]))value; break;" } 
        "default: throw new InvalidOperationException(""Bad Index"");" 
        "} } " 
    } 
    "}" 
}

{% raw %}
function script:Gen-Property 
{ 
    param ( [int] $index  = $(throw "Need an index"), [bool]$mutable = $false)

    if (-not $mutable ) 
    { 
@" 
    private readonly T{0} m_{1}; 
    public T{0} {0} {{ get {{ return m_{1}; }} }}

"@ -f $upperList[$index],$lowerList[$index] 
    } 
    else 
    { 
@" 
    private T{0} m_{1}; 
    public T{0} {0} {{ get {{ return m_{1}; }} set {{ m_{1} = value; }} }}

"@ -f $upperList[$index],$lowerList[$index] 
    } 
}
{% endraw %}
{% endhighlight %}

Now creating a mutable tuple is the same as the immutable tuple with just a name tweak.

{% highlight csharp %}
var t1 = MutableTuple.Create("foo", 42);
t1.A = "again";
{% endhighlight %}

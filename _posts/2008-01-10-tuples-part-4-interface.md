---
layout: post
---
Now we have a decent tuple generation script which produces a very usable set of tuple classes.  After awhile I ended up getting stuck because the tuples are not flexible enough.  It's not possible to use a 2 pair tuple where a 1 pair is expected even though it meets the requirements.

    
``` csharp
Process(Tuple.Create("foo"));
Process(Tuple.Create("foo", 42));

public static void Process<TA>(ITuple<TA> tuple)
{


}
```

I considered two approaches to this problem; inheritance and interface.  I debated the inheritance one for awhile.  I couldn't convince myself one way or another if a Tuple<int,int> was a Tuple<int> or merely behaved like one.  Also once we introduce a MutableTuple class inheritance won't fix the problem (unless you introduce nasty shadowing variables).  Instead I opted for an interface based approach.

In addition to defining the basic interface I added two methods to the base most interface.  These methods allow methods to operate on tuples in generic ways regardless of the pair count.

    
``` csharp
int Count { get; }
object this[int index] { get; }
```

Generating the implementation is straight forward at this point considering the past solutions.  You'll also have to alter the class definition to inherit from the appropriate ITuple interface.

Hopefully by now it's becoming clear why having a script to regenerate the large code base is a good idea.  It's easy to make sweeping changes to your implementation.

    function script:Gen-ITuple  
    {  
        param ( [int] $count = $(throw "Need a count") )   
        $OFS = ','   
        $gen = "<" + [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"       
        $base = ""   
        if ( $count -ne 1 )   
        {   
            $baseGen = "<" + [string](0..($count-2) | %{ "T"+$upperList[$_] }) + ">"       
            $base = ": ITuple$baseGen"   
        }   
        else   
        {   
            $base = ": ITuple"   
        }   
        "public interface ITuple$gen $base {"   
        "T{0} {0} {{ get; }}" -f $upperList[$count-1]    
        "}"   
    }

    function script:Gen-TupleAccess  
    {  
        param ( [int] $count = $(throw "Need a count") )   
        "public int Count { get { return $count; } }"   
        "public object this[int index] { get { switch (index){ "   
        0..($count-1) | %{ "case $($_): return m_$($lowerList[$_]);" }   
        "default: throw new InvalidOperationException(""Bad Index"");"   
        "} } }"   
    }


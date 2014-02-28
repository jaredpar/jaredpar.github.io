---
layout: post
---
[Part 5](http://blogs.msdn.com/jaredpar/archive/2008/01/22/tuples-
part-5-equality.aspx) produced equality tests for Tuples.  This section will
add comparison support through the [IComparable<T>](http://msdn2.microsoft.com
/en-us/library/4d7sx9hd.aspx) interface.  Implementing comparable is very
similar to adding equality support.  Once again there is a generic class
available to make all of the comparison decisions for us;
[Comparer<T>](http://msdn2.microsoft.com/en-us/library/cfttsh47.aspx).

The implementation will compare objects in a left to right fashion.  In this
case the property corresponding to TA will be the left most, and TN the right
most.  If all properties are equal (Compare returns 0) then the two items will
be determined to be equal and will return 0.

function script:Gen-CompareTo  
{  
    param ( [int] $count = $(throw "Need a count") )   
    $OFS = ','   
    $gen = "<" + [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"       
    "public int CompareTo(object other) {"   
    "return CompareTo(other as Tuple$gen); }"   
    "public int CompareTo(Tuple$gen other) {"   
    "if ( Object.ReferenceEquals(other,null) ) { return 1; }"   
    "int code;"   
    0..($count-1) |   
        %{ "code = Comparer<T{0}>.Default.Compare(m_{1},other.m_{1}); if (code != 0) {{ return code; }}" -f $upperList[$_],$lowerList[$_] }   
    "return 0; }"   
}

Once again the same questions arise about implementing IComparable<Tuple> vs
IComparable<ITuple> (or both).  The arguments are fairly similar and as a
result I decided to skip implementing the ITuple version for now.


---
layout: post
---
[Part 4](http://blogs.msdn.com/jaredpar/archive/2008/01/10/tuples-part-4-interface.aspx) left us with a reusable, abstract and inference friendly Tuple class. The next step is to be able to test for Tuple equality.  

For the Tuple implementation, two tuples will be defined as equal if all of their members are equal. Seems fairly straight forward. The trick is in the implementation. In addition to doing the typical override of Equals/GetHashCode the Tuple implementation will be implementing [IEquatable<T>](http://msdn2.microsoft.com/en-us/library/ms131187.aspx) and overloading the standard equality operators.  Tuple members are all unconstrained generic classes which leaves us with a non-great starting point.

For instance what if we are dealing with value types' Is Equals() the best method to call' What if the type in question implements [IEquatable<T>](http://msdn2.microsoft.com/en-us/library/ms131187.aspx) or has a well known [IEqualityComparer<T>](http://msdn2.microsoft.com/en-us/library/ms132151.aspx)'?? What if one or both of the arguments are reference types and null? What if they're value types and equal to null?

Luckily there is an easy and straight forward solution. The BCL defines a class, [EqualityComparer<T>](http://msdn2.microsoft.com/en-us/library/ms132123.aspx), which will properly perform equality comparisons for objects of a particular type. This makes the Equals override very straight forward.

There is one small trick to implementing Equals correctly. The implementation explicitly uses Object.ReferenceEquals to check for null rather than ==. The reason being is once operator== is defined for the type Tuple, comparison for even null will bind to this operator. Part of checking for operator== will end up calling Equals and hence you can end in a stack overflow fairly quick.  Note that our implementation of == will work around this but it's still safer to be explicit.

    function script:Gen-Equals  
    {  
       param ( [int] $count = $(throw "Need a count") )  
       $OFS = ','  
       $gen = "<" \+ [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"  
       "public override bool Equals(object obj) { "  
       "return Equals(obj as Tuple$gen); }"  
       "public bool Equals(Tuple$gen other) {"  
       "if ( Object.ReferenceEquals(other,null) ) { return false; }"  
       "if ("  
       $OFS = "&&"  
       [string](0..($count-1) |
    %{"EqualityComparer<T{0}>.Default.Equals(m_{1},other.m_{1})" -f
    $upperList[$_],$lowerList[$_] })  
       ") { return true; }"  
       "return false;"  
       "}"  
    }

GetHashCode can also utilize [EqualityComparer<T>](http://msdn2.microsoft.com/en-us/library/ms132123.aspx).

    function script:Gen-GetHashCode  
    {  
       param ( [int] $count = $(throw "Need a count") )  
       "public override int GetHashCode() {"  
       "int code = 0;"  
       0..($count-1) | %{ "code +=
    EqualityComparer<T{0}>.Default.GetHashCode(m_{1});" -f
    $upperList[$_],$lowerList[$_] }  
       "return code;"  
       "}"  
    }

Both of the operators are likewise straight forward. As before mentioned [EqualityComparer<T>](http://msdn2.microsoft.com/en-us/library/ms132123.aspx) will properly check for null and then perform an Equals call so it can be used as the standard operator code.

    function script:Gen-OpEquals  
    {  
       param ( [int] $count = $(throw "Need a count") )  
       $OFS = ','  
       $gen = "<" \+ [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"  
       "public static bool operator==(Tuple$gen left, Tuple$gen right) {"  
       "return EqualityComparer<Tuple$gen>.Default.Equals(left,right); }"  
       "public static bool operator!=(Tuple$gen left, Tuple$gen right) {"  
       "return !EqualityComparer<Tuple$gen>.Default.Equals(left,right); }"  
    }

In addition to the methods, the Tuple class generation must be changed to implement IEquatable<Tuple<>>.

Some will notice that the implementation forces the equality comparison to be against a Tuple<T> vs an ITuple<T>. There are a couple of reasons for this.

  1. I have come up against specific scenarios where I wanted to compare Tuple<T> but not ITuple<T>. This is not saying they don't exist (they do). But I prefer to leave an implementation until I find a justification for implementing it.
  2. By constraining to IEquatable<Tuple<T>> we are always comparing apples to apples. If you try and perform an Equals against ITuple<TA> you're leaving yourself open to comparing apples and oranges. Since ITuple<TA,TB> implements ITuple<TA> it is a valid target for the overload. This type of equality seems scenario dependent and as such I left it out for the time. Note with our current implementation it would be very easy to come back and add this later.
  3. To make #2 even stranger, once MutableTuples are implemented an implemantation of IEquatable<ITuple<TA>> might actually be comparing Tuple<TA,TB,TC> to MutableTuple<TA>.


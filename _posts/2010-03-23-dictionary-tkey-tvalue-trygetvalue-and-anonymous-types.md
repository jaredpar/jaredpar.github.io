---
layout: post
---
One of the methods I find to be the most useful in .Net is the method
[Dictionary<TKey,TValue>.TryGetValue](http://msdn.microsoft.com/en-
us/library/bb347013.aspx). This method is a nice compromise between
performance, explicit return vs. exception, and a being verbal about the
chance of failure. It returns false on failure and uses an out parameter to
return the actual requested value. This leads to the following elegant
pattern

    
    
    Student value;


    if (map.TryGetValue("SomeKey", out value)) {


        // Value is present


    }


    else {


        // Value is not present


    }

This works great right up until have a Dictionary of anonymous types. The
TryGetValue pattern functions on out parameters which do not work well with
type inference in C# and hence anonymous types. Type inference requires that
the value be declared with a corresponding initialization expression. But any
out call forces the declaration of the type and the initialization expression
to be different statements breaking any chance of type inference.

For example take the following code which builds up a Dictionary object where
the value is typed to be an anonymous type [1]

    
    
    var query = from it in GetStudents()


                where it.LastName.StartsWith(lastNamePrefix)


                select new { FirsName = it.FirstName, LastName = it.LastName };


    // ...


    var map = query.ToDictionary(x => x.FirsName);


    


    // How to use TryGetValue?  


    WhatDoIPutHere' value;


    if ( map.TryGetValue("Joe", out value) {


        // ...


    }

To fix this problem we need to write a wrapper around TryGetValue which allows
us to combine both the presence or absence of the entry in the Dictionary and
the resulting looked up value if present.'? Within our wrapper method we can
use type inference tricks to avoid naming the anonymous type directly. To
combine the values could construct a new type say TryGetValueResult<TValue>

    
    
    struct TryGetValueResult<TValue> {


        public readonly bool Success;


        public readonly TValue Value;


        public TryGetValueResult(bool success, TValue value) {


            Success = success;


            Value = value;


        }


    }

But I find this to be a bit heavy handed for a simple return. Instead I
prefer to combine the data with the new
[Tuple<T1,T2>](http://msdn.microsoft.com/en-
us/library/dd268536\(VS.100\).aspx) type introduced in 4.0.'? This type is
designed to be a light weight method for combining two related values into a
single instance. Perfect for this type of method.

    
    
    public static Tuple<bool, TValue> TryGetValue<TKey, TValue>(


        this Dictionary<TKey, TValue> map, 


        TKey key) {


    


        TValue value;


        var ret = map.TryGetValue(key, out value);


        return Tuple.Create(ret, value);


    }

Now that we've built our wrapper method we can go back to the original code
sample and use it to access the anonymous type values

    
    
    var tuple = map.TryGetValue("Joe");


    if (tuple.Item1) {


        Console.WriteLine(tuple.Item2);


    }

This pattern is not limited strictly to TryGetValue. It's fairly applicable
anytime you need to combine a return value and one or more out parameters into
a single value for reasons of type inference.



[1] Believe it or not, having a Dictionary where the value type is an
anonymous type is not a wholly uncommon act. I've run into a bit of customer
code which follows this general pattern


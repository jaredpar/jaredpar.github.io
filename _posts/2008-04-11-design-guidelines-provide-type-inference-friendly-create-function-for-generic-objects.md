---
layout: post
---
Really this guideline is a bit longer but putting it all in a blog title seemed a bit too much. The full guideline should read: "If a generic class constructor arguments contain types of all generic parameters, provide a static method named Create on a static class of the same class name as the generic class which takes the same arguments and calls the constructor." Quite a mouth full.

Lets look at a specific example with [Tuples]({% post_url 2008-01-27-tuples-part-8-finishing-up %}). Tuples are generic with respect to the values they are representing. Without any type inference help we would have to write the following code to create a simple tuple.

``` csharp
var tuple = new Tuple<int, string>(5, "astring");
```

Not too bad because we are using simple types. But what happens when we are using really long type names?
    
``` csharp
var tuple2 = new Tuple<string,Dictionary<string, List<int>>>(val1, val2);
```
    
As we can see, the code is getting quite a bit uglier. This pattern is in fact not maintainable once we start using un-namable types such as anonymous types or generics of anonymous types.

The problem here is we are not leveraging the compilers type inference capabilities. The compiler can easily infer the types of a tuple argument and hence create a tuple. We just need to provide a mechanism to do so. The best way is to define a static method on a static class with the same name as the generic. Lets call this method Create.

``` csharp
public static class Tuple {
    public static Tuple<TA, TB> Create<TA, TB>(TA valueA, TB valueB) { 
        return new Tuple<TA, TB>(valueA, valueB); 
    }
}
```

The method Tuple.Create still has two generic parameters. However since we are providing a set of values which contain types for every generic parameter, the compiler can infer the generic arguments. Now we can create a Tuple without specifying any generic arguments. Because no types are specified this will work with any value in the code including un-namable types.
    
``` csharp
var tuple = Tuple.Create(6, "astring");
var tuple2 = Tuple.Create(6, new { name = "aname", value = 42 });
```


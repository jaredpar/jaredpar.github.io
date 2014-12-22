---
layout: post
---
While updating my VsVim editor extensions for Beta2 [^1] I got hit by a change in the way F# exposed discriminated unions in metadata. My extension consists of a core F# component with a corresponding set of unit tests written in C#.  It's mostly API level testing and as such I use a lot of F# generated types in my C# test assembly.

In Beta1 all information which could be extracted from a discriminated type union was immediately available on the value. The underlying type presentation was less than desirable but these details were hidden by type inference and the very accessible API.'? The type wasn't perfect because given a particular instance only the subset of the properties relevant to the union value type were valid. All others threw exceptions. But the code use of these methods and properties flowed very well.

For instance take the following F# definition

    
``` fsharp
type ActionKind =
    | Mouse = 1
    | Keyboard = 2

type ActionResult =
    | Complete of (ActionKind * int)
    | Error of string
    | NeedMore of (char -> ActionResult)
```

The use case in C# was quite simple

``` csharp
[TestMethod]
public void TestActionBeta1(){
    var res = GetResult();
    Assert.IsTrue(res.IsComplete());
    Assert.AreEqual(ActionKind.Mouse, res.Complete1.Item1);
    Assert.AreEqual(42, res.Complete1.Item2);
}
```

Notice how no type information is necessary and the code flows quite naturally. C# type inference works great here and allows me to do what I need to do without fussing around with little stuff. The type in this case is a detail I don't need to know about. It simply adds no value.

Discriminated Unions in Beta2 changed substantially in this area. Instead of generating the set of all values on the exposed type, there is now an inner type generated for every discriminated union value and the properties relevant to that union value are stored on the inner type. The outer type now contains only properties to determine which type of value it is (certainly an upgrade from methods!) [^2]

For instance in the case of ActionResult there are 3 generated inner classes: Complete, Error and NeedMore. Each one contains a single property Item which contains the associated value(s). This means to get to the value portion a cast to the inner type must be inserted!

Lets take a a look at how the above test code has to change to deal with the Beta2 generation of ActionResult.

``` csharp
[TestMethod]
public void TestActionBeta2() {
    var res = GetResult();
    Assert.IsTrue(res.IsComplete);
    Assert.AreEqual(ActionKind.Mouse, ((ActionResult.Complete)res).Item.Item1);
    Assert.AreEqual(42, ((ActionResult.Complete)res).Item.Item2);
}
```

Notice the explicit casts which must be added to access the values. This makes it impossible to rely soley on C# type inference. I must now understand the underlying type structure of discriminated unions in order to use them.  This extra cast adds no real value to my code.

My C# test assembly has literally hundreds of test cases which use this pattern on F# types. I didn't know the return type of every method and found myself hitting 'Goto Def' on a lot of 'var' instances to discover the static type, going back to the original file and inserting the cast. It was a tedious and slow process.

Eventually I settled on a different solution. For every type I exposed in F# I added a set of extension methods in the form of AsXXX where XXX represented the name of the generated inner types.'? For example
    
``` csharp
public static ActionResult.Complete AsComplete(this ActionResult res) {
    return (ActionResult.Complete)res;
}
```

The advantage of this approach is 2 fold

  1. Removes the need to explicitly name types in code and hence gets back the advantages of type inference
  2. I can now use . on any of the values and let Intellisense help me find the appropriate method to use

This extension method allows me to get closer to the Beta1 style code

``` csharp
[TestMethod]
public void TestActionBeta2() {
    var res = GetResult();
    Assert.IsTrue(res.IsComplete);
    Assert.AreEqual(ActionKind.Mouse, res.AsComplete().Item.Item1);
    Assert.AreEqual(42, res.AsComplete().Item.Item2);
}
```

With these methods and a quick series of Find / Replace calls, I was back in business.

[^1]: It's coming I promise!

[^2]: It also contains a handy set of factory methods for generating values but it's not relevant to this discussion.


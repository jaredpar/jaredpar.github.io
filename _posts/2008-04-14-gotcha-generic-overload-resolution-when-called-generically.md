---
layout: post
---
Both VB and C# have a feature of generic overload resolution that is fairly helpful and yet a source of gotchas.  Lets say you have two methods with the same number of arguments.  One method has arguments with generic types and the other does not.  For Example:

    
``` csharp
class C1<T> {
    public void F1(int ival) {
        Console.WriteLine("Non-generic F1");
    }
    public void F1(T val) {
        Console.WriteLine("Generic F1");
    }
}
```

Imagine what happens when we have a C1<int> and call F1(5).  Which method should the compiler bind to?  Both VB and C# when presented with this type of situation will choose the non-generic version.
    
``` csharp
v1.F1(5);           // Binds to Non-generic F1
v2.F1("foo");       // Binds to Generic F1
```

At a glance we might think that we can provide specialized behavior for a subset of types that are interesting (similar to C++ template specialization).  If VB/C# will bind to our non-generic version then we don't have to due ugly type switching to implement different behavior for certain types.  Unfortunately we would be wrong.

This type of overload resolution only happens if the compiler can statically verify that the argument matches a non-generic overload.  So if we call F1 generically it will not bind to the non-generic overload.  
    
``` csharp
static void TestOverload<T>(C1<T> weird, T value) {
    weird.F1(value);
}

static void Main(string[] args) {
    var v1 = new C1<int>();
    var v2 = new C1<string>();

    TestOverload(v1, 5);        // Binds to Generic F1
    TestOverload(v2, "foo");    // Binds to Generic F1
}
```
     


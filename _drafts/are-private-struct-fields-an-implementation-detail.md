---
layout: post
title: Are private struct fields an implementation detail?
---

A reference assembly is a slimmed down version of an assembly that contains types and members but no actual code.  A program can reference these assemblies at compile time but cannot run against them.  Instead at deploy time programs are paired with the original implementation assembly.

Breaking up assemblies into reference and implementation parts is a useful tool for creating targeted API surfaces.  The author is free to exclude public types / members and hence create a more constrained API surface. This is in fact how targeting PCL, Windows 8, UWP, etc ... works.  

The other advantage though is reference assemblies are significantly smaller than their counterparts.  After all they have no code and can remove all of the non-accessible APIs since they don't impact compilation. This means SDKs consisting of reference assemblies can be quite small.  

One question that frequently comes up when creating reference assemblies is what members on types are safe to omit? On the surface this seems like a simple question: just exclude the members of the type that have no impact on compilation.  

Many developers take this to mean they only need to include `public` and `protected` members as they are the only members accessible outside the assembly.  This breaks down in the face of `InternalsVisibleTo` attributes as it makes `internal` members accessible as well.  In that case a reference assembly must include the `internal` members of a type to be complete.

Surely though `private` members can be excluded?  There is no `PrivatesVisibleTo` attribute hence external compilations can't ever access these members. They are simply an implementation detail.

While that is generally true, there is one case where `private` members have a meaningful effect on other programs: struct fields.  The presence, or absence, of these fields can change the way in which the containing struct can be used.  The details are often subtle but there are a number scenarios involved.

## Pointer Types

C# permits user defined structs to be pointer types in unsafe code provided the struct meet a specific guideline: it must not contain any fields that are of a reference type [^1].  This requirement exists because the .NET GC does not trace through pointers to find object references.  Hence they are neither tracked for liveness nor are their addresses rewritten if the object moves during compaction.

Knowing that consider the effect of removing private fields on the following struct:

``` csharp
// Implementation assembly definition
public struct S
{
    private object _field;

    public static S GetValue()
    {
        return new S() { _field = new object(); };
    }
}

// Reference assembly definition
public struct S
{
    public static S GetValue()
    {
        throw new NotImplementedException();
    }
}
```

The reference assembly definition meets the C# standard for pointers.  This means any program using the reference assembly could legally author the following:

``` csharp
S* p = Marshal.CoTaskMemAlloc(sizeof(S*));
*p = S.GetValue();
```

This is extremely dangerous because now there is a reachable object reference which is untracked by the GC.  It's a crash in the application just waiting to happen.  

This behavior difference is also visible in safe code, albeit in a much less severe fashion as C# allows `typeof` to target pointer types in any context.  The following will compile against the reference assembly but not the implementation assembly.

``` csharp
Console.WriteLine(typeof(S*));
```

## Generic Expansion

When constructing generic instantiations that involves structs C# needs to verify that it doesn't create a struct cycle.  For example:

``` csharp
public struct Container<T>
{
    private T _field;
}

public struct Usage
{
    Container<Usage> Data;
}
```

The definition of `Usage` here is illegal because it creates a cycle between `Container<T>` and `Usage`.  Specifically between the fields `_field` and `Data` whose types depend on each other cyclically.  This makes it impossible to define the shape of the struct `Usage` and hence C# correctly flags it as illegal.

Now consider what happens if `Container<T>` is defined in a reference assembly that strips `private` fields:

``` csharp
// Reference assembly definition
public struct Container<T>
{

}
```

The lack of the `T` field means there is no cycle and C# allows the definition of `Usage` to compile.  This would then blow up at runtime as the CLR can't represent this definition.

This particular scenario is interesting because it's not limited to C#.  It affects any .NET language that implements generics: C#, F#, VB and C++/CLI.

## Definite Assignment

Definite assignment is the process by which C# ensures programs only use variables which are properly initialized.  In general the rules are very straight forward and can be summarized as variables must be assigned or used in an `out` position before they are referenced as a value.  

Structs are an interesting case because definite analysis only requires that all of the fields of a struct are assigned a value [^1].  This can be done by calling a constructor, using `default(T)` or initializing all fields by hand. This last case is interesting because it allows for structs to be considered initialized without every being assigned a value as a whole:

``` csharp
struct Point
{
    public int X;
    public int Y;
    public override string ToString() => $"{X} - {Y}";
}

Point p;
Console.WriteLine(p); // Error! p is not initialized
p.X = 0;
p.Y = 0;
Console.WriteLine(p); // Okay, it's initialized at this point
```

This logic also applies to struct values which have no fields.  Instances of such types are trivially considered to be initialized:

``` csharp
struct Example
{

}
Example e;
Console.WriteLine(e); // Okay, e is trivially initialized.
```

Knowing that consider what happen to the usage of a struct consisting of only `private` fields if they are stripped away:

``` csharp
// Implementation assembly definition
public struct Rectangle
{
    private int Width;
    private int Height;
}

// Reference assembly definition
public struct Rectangle
{

}
```

To other programs `Rectangle` now appears as an empty struct.  That means it can be used without any assignment (as `Example` was above).  This creates an observable difference between programs that compile against the reference and implementation assembly.

To be fair here: this is not a violation of IL but only C# rules.  Other languages, notably VB, specifically allow for using variables before they are properly initialized.  It does however cause observable breaks in C# applications.

### Conclusion

The scenarios above are just the most common, and severe, consequences of stripping `private` fields from structs in reference assemblies.  There are several other less severe ones that are affected:

- Explicit struct layouts: can't be done if there is a reference type field.
- Interop: developer needs to know true size to design interop correctly.

All of these scenarios though add up to one, unfortunate, conclusion.  Private structs fields cannot be considered just an implementation detail.  They are instead an observable part of the struct's contract.  

[^1]: This was done in part to ease the porting from C programs.

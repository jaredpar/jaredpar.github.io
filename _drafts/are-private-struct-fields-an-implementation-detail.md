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


Effects: C#

## Field Offset

Effects: IL verification

## Interop

Effects: C#, VB, F#

For instance internal members can't be removed if there are any `InternalsVisibleTo` attributes because the member could be accessed from an outside assembly.  Private members are never accessible hence they can be removed.

This is a trickier question than



That means `internal` members can be excluded correct?  

Not so fast.   


- Smaller SDKs: Lack of code means the DLL is significantly smaller.
- Targeted APIs: The types and members in the reference assembly can be any consistent set

A reference assembly is a .NET assembly that contains
A reference assembly is a .NET assembly that contain accessible types and members but no actual code.  It is a API only assembly that programs can compile, but not run, against.  They are paired with implementation assemblies which have the
Frameworks are often broken up into reference
It is essentially a contract only assembly that programs can compile, but not run against.  
It is paired with an implementation assembly which contains types, members and code.  Programs compile against reference assemblies and run against actual implementation assemblies.


In object oriented programming developers are taught to use accessibility to control the parts of the type which are visible to consumers.  Keep the accessible members to the minimum necessary and use the

This is a nice mental model to have but unfortunately reality gets in the way with structs in .NET.  Their properties and usage in .NET languages combine to mean private fields are never an implementation detail.  Their presence, or absence, observably affect how code compiles and executes.  

These details come up most often in discussions around reference assemblies.  A reference assembly is a .NET assembly that contains types and members but no actual code.  An implementation assembly contains types, members and code. Programs compile against reference assemblies and run against actual implementation assemblies.

Breaking up assemblies into reference and implementation parts [^1] is a useful tool for creating targeted API surfaces.  This is in fact how targeting PCL, Windows 8, UWP, etc ... works.  

In order to create correct reference assemblies you can't remove members  from types that meaningfully affect compilation.   

That is true in the majority of cases.  The one case it is not

This is a useful tool for pairing down large implementation assemblies into more targeted API surfaces.  

The APIs can be carefully controlled without having to change the implementation assembly at all.  It's



 (this is in fact how targeting PCL, Windows 8, etc... works).  

It's a useful tool for pairing down large assemblies into more manageable API surfaces (often having multiple reference assemblies per implemenation DLL


** Pointer Types **



Developers want to operate under the principle that private fields are merely implementation details of a type.  

Unfortunately this doesn't a


**CSharp**

This is one area where there is no ambiguity.  The C# language does not consider private fields on struct an implementation detail.  Instead it has clear impact on how types are used:

- Definite assignment
- Unmanaged type: fixed, unsafe, etc ...

**IL**



**Developers**

This is a more ambiguous question.

[^1]: Known as an "unmanaged type" in the C# spec which is defined in section 18.2.  

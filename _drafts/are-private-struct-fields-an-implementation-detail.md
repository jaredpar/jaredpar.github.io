---
layout: post
title: Are private struct fields an implementation detail?
---

A reference assembly is a slimmed down version of an assembly that contains types and members but no actual code.  A program can reference these assemblies at compile time but cannot run against them.  Instead at deploy time programs are paired with the original implementation assembly.

Breaking up assemblies into reference and implementation parts is a useful tool for creating targeted API surfaces.  The author is free to exclude public types / members and hence create a more constrained API surface. This is in fact how targeting PCL, Windows 8, UWP, etc ... works.  

The other advantage though is reference assemblies are significantly smaller than their counterparts.  After all they have no code and can remove all of the non-accessible APIs since they don't impact compilation. This means SDKs consisting of reference assemblies can be quite small.  

One question that frequently comes up when creating reference assemblies is what members on types are safe to omit? On the surface this seems like a simple question: just exclude the members of the type that have no impact on compilation.  

Many developers take this to mean they only need to include `public` and `protected` members as they are the only members accessible outside the assembly.  This breaks down in the face of `InternalsVisibleTo` attributes as it makes `internal` members accessible as well.  In that case a reference assembly must include the `internal` members of a type to be complete.

Surely though `private` members can be excluded?  There is no `PrivatesVisibleTo` attribute hence external compilations can't ever access these members.  While it's true `private` members can't be bound to there is one kind of `private` member which can create observable, and meaningful, effects on external program: fields of a struct.  




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

---
layout: post
title: Are private struct fields an implementation detail?
---

In object oriented programming developers are taught to use accessibility to control the parts of the type which are visible to consumers.  Keep the accessible members to the minimum necessary and use the

This is a nice mental model to have but unfortunately reality gets in the way with structs in .NET.  Their properties and usage in .NET languages combine to mean private fields are never an implementation detail.  Their presence, or absence, observably affect how code compiles and executes.  

These details come up most often in discussions around reference assemblies.  A reference assembly is a .NET assembly that contains types and members but no actual code.  An implementation assembly contains types, members and code. Programs compile against reference assemblies and run against actual implementation assemblies.

Breaking up assemblies into reference and implementation parts [^1] is a useful tool for creating targeted API surfaces.  This is in fact how targeting PCL, Windows 8, UWP, etc ... works.  

In order to create correct reference assemblies you can't remove members  from types that meaningfully affect compilation.  For instance internal members can't be removed if there are any `InternalsVisibleTo` attributes.  

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

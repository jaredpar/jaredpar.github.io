---
layout: post
title: Invalid Uses Of a Type
---
I joined a discussion recently about a new API being added to a type with well established semantics.  The API seemed to violate the key invariants of the type and I was curious about the justifications.  Of the various reasons given one in particular stood out to me as questionable: 

> The type can already be used in this manner hence this API adds nothing new to the equation, it just standardizes the behavior

Typically this is a really good justification for adding an API.  Centralizing similar code snippets into a single API lowers maintenence cost, reduces code duplication, etc ...  As previously stated though this seemed like a violation of established semantics so I dug into the provided samples.  They all fell into the following categories: 

1. Unsafe Code
2. Unverifiable Code
3. Private Reflection

This is an argument I've heard before but it's not one that adds any weight for me.  Code samples of this nature are intentionally violating the type system and should not be considered a valid use of the type.  

If samples of this nature were considered valid then they could be used to justify practically any API on a type.  For example this argument could be applied to adding a setter on the indexer of [string](http://msdn.microsoft.com/en-us/library/system.string(v=vs.110).aspx).  After all with `unsafe` code I can already mutate its contents so by this reasoning mutations are valid:

```
string s = "cat";
unsafe {
    fixed (char* i = s) {
        // "cat" becomes "bat"! 
        *i = 'b';
    }
}
```

Clearly though `string` is an immutable type and making it mutable would invalidate loads of existing code in the wild.  No developer out there designed their programs considering the impacts of a `string` being mutated.  That would be a waste of brain power.   

That is why I consider this type of example to be flawed.  The above listed techniques exist purely to violate the verifiable type system and to bypass object accessibility.  By definition they are using a type in a way that it was never meant to be used.  These are simply not valid samples.


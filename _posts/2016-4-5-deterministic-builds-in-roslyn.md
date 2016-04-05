---
layout: post
title: Deterministic builds in Roslyn
tags: [roslyn, c#, vb]
---
It seems silly to celebrate features which should have been there from the start.  But I can't help but be excited about adding deterministic build support to the C# and VB compilers.  The `/deterministic` flag causes the compiler to emit the **exact** same EXE / DLL, byte for byte, when given the same inputs. This is a seemingly minor accomplishment that enables a large number of scenarios around content based caching: build artifact, test results, etc ...

Roslyn for example enabled deterministic builds in February.  Since then we've built a content based test caching system leveraging our deterministic build output that on average provides 72% savings on the time it takes to run tests.  That's a huge productivity boost for developers because our changes can be verified almost 15 full minutes faster now in PRs!!!

Getting a bit ahead of ourselves though.  Let's discuss what exactly the deterministic switch does to the PE output.

### Deterministic Compilations
When discussion determinism compilations we need to divide up the contents of the PE into two categories:

- The inherently non-deterministic values
- Everything else

Everything else includes the order and content of classes, methods, attributes, etc ...  In the past the compiler has never made any explicit guarantees about the order in which these items are emitted.  Yet in practice both Roslyn and the native compiler emitted these values deterministically based on the order in which inputs were received to the compiler.  Because this was never guaranteed it was not explicitly tested and hence there were some subtle sources of non-determinism.

Going forward this deterministic ordering is now guaranteed by the compiler irrespective of the `/deterministic` flag.  This does not guarantee a specific ordering such as the first class provided to the compiler will be the first class emitted.  Instead it guarantees that given the same source files in the same order the compiler will emit the classes / members in the same sequence in the PE.  

That leaves us with the inherently non-determistic values in the PE:

- MVID: a GUID identifying the PE which is newly generated for every PE produced by the compiler [^1].
- PDB ID: a GUID identifying the PDB matching PDB which is newly generated on every build.
- Date / Time stamp: Seconds since the epoch which is calculated on every build.

These three values are the root of non-determinism in the compiler.  Everything else has always been, mostly, emitted deterministically.  These values though change on every build, even if provided identical inputs, and hence are the root cause of non-determinism in PEs.

There are a small number of indirectly non-determinismic values, such as PrivateImplementationDetails.  These derive names from the values above and hence are also non-deterministic.  These are secondary issues though, the MVID, PDB ID and Timestamp are the core issues to solve for deterministic builds.

At the core the `/deterministic` flag simply acts to make these values deterministic while maintaining their original function.  In particular the MVID and PDB ID need to still be a unique identifier of the PE and PDB respectively.  Using a GUID such as all 0s would be deterministic but would break existing tools which attempted to identify / cache a PE by it's MVID entry [^2].  

To create the MVID and time stamp with repeatable unique values the compiler uses cryptographic hashes.  It takes the content of the PE with the above entries set to 0 and runs it through a SHA1 [^3] hash.  The resulting 20 bytes are then carved up into a GUID (16 bytes) and a time stamp entry (4 bytes, high bit always set).  A similar operation is performed for the PDB ID.  This means the above values will be repeatable and unique for a given set of inputs.  

The combination of the explicit ordering guarantee and the predictable values for MVID, PDB ID and timestamp allow us to produce fully deterministic PE outputs from the compiler.  They will be identical byte for byte.

### FAQ

A couple of questions that often come up in this area:

#### Why not just use all 0s for the timestamp?
This is actually how the original implementation of determinism functioned in the compiler.  Unfortunately it turned out there were a lot of tools we used in our internal process that validated the timestamp.  They got a bit cranky when the discovered binaries claiming to be written in 1970, over 25 years before .NET was even invented.  The practice of validating the time stamp is questionable but given tools were doing it there was a significant back compat risk.  Hence we moved to the current computed value and haven't seen any issues since then.  

#### Why isn't this behavior enabled by default?
There is one case where the `/deterministic` can cause a compilation error: the use of `*` in `AssemblyVersionAttribute` or `AssemblyFileVersionAttribute`.  The use of `*` here specifies a value that is required to change on every build (or at least every day).  That conflicts directly with `/deterministic` which pushes the compiler to produce a byte for byte equivalent build given the same inputs.  Hence the compiler issues an error notifying the developer of the conflict.

There has been significant discussion around relaxing this case to a warning in C# 7.0 and making deterministic the default.  This is on going discussion but I'm optimistic it will happen.

#### What does the /deterministic switch actually control?
It serves to make the inherently non-determinismic sections of the PE deterministic: MVID, PDB ID and time stamp.  All of the other section of the PE are deterministic with or without the switch being present.

#### Is the PDB deterministic as well?
Windows PDBs still have non-deterministic output.  These are emitted by a native component shared by the C++ compiler.  Attempts were made to make the output of the PDB deterministic as well but fell short for this release.  It's possible in future releases this will also become fully deterministic.

Portable PDBs are fully deterministic.  They were designed with determinism in mind and are fully deterministic in the face of the `/deterministic` flag.

#### What if I build from different enlistment paths?
There are a number of cases where the enlistment path of a build will show up in the resulting PE / PDB:

- Full path of source files are embedded in the PDB.
- `[CallerFilePath]` embeds full source path as a default argument.
- `#line` directives can include file paths.
- The full path of the PDB if generated.

This means identical builds from different enlistment paths will often have different outputs.  To fix this the compiler provides the `/pathmap:` option.  It takes arguments in the form of `/pathmap:<source directory>=<dest directory>`.  Multiple pairs can be provided by separating them with a semicolon.  

When given this option the compiler will replace the any occurrence of `<source path>` in file path it writes out with `<dest path>` instead.  This allows builds from different enlistment paths to have identical output.

Note: If producing PDBs then in update 2 the following flag also needs to be provided: `/feature:pdb-path-determinism`.  This is a short term work around that [will be replaced](https://github.com/dotnet/roslyn/issues/9813) with a supported option in update 3.

#### What options do I provide in MSBuild files?
Here are the MSBuild project file entries for the equivalent command line option:

- `/deterministic` - `<Deterministic>true</Deterministic>`
- `/pathmap` - `<PathMap>source=dest</PathMap>`

#### What inputs to the compiler affect deterministic output?
See the [Deterministic Inputs](https://github.com/dotnet/roslyn/blob/56f605c41915317ccdb925f66974ee52282609e7/docs/compilers/Deterministic%20Inputs.md) document in the Roslyn repo.



[^1]: The CLI spec suggests this "should" be newly generated for every PE and practically all tools that output PEs use `Guid::NewGuid()`.
[^2]: A common practice in complex build environments.
[^3]: The use of SHA1 is subject to change in future releases of the compiler.

---
layout: post
title: Improving the Display of seq<T> in the Debugger
---
F#'s seq<T> expressions are a frustrating item to inspect at debug time. A seq<T> value is a collection and when users inspect such a value at debug time they want to see the contents of the collection. Instead they are often presented with a view resembling the following

![seq1](http://blogs.msdn.com/cfs-file.ashx/__key/CommunityServer-Blogs-Components-WeblogFiles/00-00-00-39-97-metablogapi/5810.seq1_5F00_thumb_5F00_47D066E9.png) 

The reason this happens is a consequence of how the debugger works. When a value is expanded it essentially enumerates the members and display the values as child nodes. This is great for most types of objects where the members hold the mots interesting data. For collections though it's often far more interesting to see the elements in the collection.

Most collection types don't have this issue because they are either custom handled by the expression evaluator, arrays for example, or use a debugger type proxy helper class (Dictionary<TKey,TValue>, List<T>, etc ').'? One class of collections that do not display well are C# iterators and F# seq expressions. Both languages translate these into generated types which expose IEnumerable<T>. The type contains no custom type proxy helper classes and expression evaluators don't custom handle them. Users cannot fix the problem either by adding a custom DebuggerTypeProxy because they are generated types and hence not directly accessible to the user.

The languages team realized this was a problem and added a debugger feature in Visual Studio 2008 to help: the 'Results View' node. When an expression appears in the locals or watch window which is typed to IEnumerable<T> and has no associated DebuggerTypeProxy the expression evaluator will add a special child named Results View. When this is expanded it will enumerate the IEnumerable and display the values. Here is the equivalent C# sequence displayed in 2008 and beyond.

![seq2](http://blogs.msdn.com/cfs-file.ashx/__key/CommunityServer-Blogs-Components-WeblogFiles/00-00-00-39-97-metablogapi/0458.seq2_5F00_thumb_5F00_46F800FF.png) 

This display is much better because it's actually showing me the elements in the IEnumerable<T>!!!

Astute readers may be wondering at this point why this doesn't work for F# out of the box. After all F#'s seq<T> maps to IEnumerable<T> and the F# debugging experience uses the C# expression evaluator. So there should be no difference in the experience here.All of this is true, there's just one small problem.  The C# (and VB) expression evaluators don't actually do the work of enumerating the IEnumerable<T>. Instead they rely on a helper class defined in System.Core.dll. If this DLL is not loaded then the Results View node can't be created. The C# and VB.Net project system work to have System.Core, and other important DLL's, loaded at the start of a debugging session. The F# project system does not do this and hence misses out on this experience by default.

Developers can get this experience in F# by forcing System.Core.dll into the debugee process. My favorite trick is to add the following line at the start of my F# applications.

    
``` fsharp
#if DEBUG
System.Linq.Enumerable.Count([]) |> ignore
#endif
```

This forces System.Core.dll into the process in debug builds which results in a much nicer display for any seq<T> expressions I have.

![seq3](http://blogs.msdn.com/cfs-file.ashx/__key/CommunityServer-Blogs-Components-WeblogFiles/00-00-00-39-97-metablogapi/5226.seq3_5F00_thumb_5F00_05E9819B.png)

When I originally posted this solution to a [question](http://stackoverflow.com/q/3512266/23283) on StackOverflow, [Tim Robinson](http://stackoverflow.com/users/32133/tim-robinson) pointed out that it's possible to force System.Core.dll into the debugee process without adding extra debug code to the process. Simply use the Assembly.Load API to do it by evaluating the following expression in the watch window.

> System.Reflection.Assembly.Load("System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089, processorArchitecture=MSIL"

I still prefer my solution but this is a great trick to have if developers are in a situation where they can't edit the code. Such as debugging in a production environment.  

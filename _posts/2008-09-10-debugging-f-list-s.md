---
layout: post
---
One of the lacking's of the latest F# CTP is debugger visualization support for the built-in list types. Viewing a list in the debugger is decidedly tedious compared to the mscorlib collection classes. Take the following quick code sample

``` fsharp
module Main =
    do
        let l1 = [0..4]
        let l2 = List.map (fun a -> a.ToString()) l1
        let l3 = new System.Collections.Generic.List<int>()
        List.iter (fun i -> l3.Add(i)) l1
        MainModuleTemp.Main()   // Breakpoint here
```

Hit F5 in a F# console application and you'll get the following display.

![image](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/DebuggingFlists_129AA/image_thumb.png)

Notice how the elements of the mscorlib List<> are immediately visible.  Getting to the data in a F# list is possible but it takes a lot more clicks than the mscorlib version. This doesn't appear to be an oversight on the F# team either. The expansion of mscorlib List<T> is controlled by the DebuggerTypeProxy attribute on the class definition. If you fire up Reflector and dig into Fsharp.Core.dll and navigate to List<T> you'll notice it indeed has a DebuggerTypeProxy entry which is well formed and points to ListDebugView<T>.

ListDebugView<T> is essentially identical to the one for mscorlib List<T>. So what gives' The bug appears to be in the accessibility of the constructor.  Even though it's not explicit in the documentation of DebuggerTypeProxy, it appears that the target type must have a single argument constructor which is public. The one for ListDebugView<T> is internal.

Normally this would be an easy enough problem to work around. Add an assembly level attribute of type DebuggerTypeProxy pointing to List<T> and a modified version of ListDebugView. Unfortunately that will not work in this case. The debugger will prefer DebuggerTypeProxy instances added directly to a type over ones defined at an assembly level.

That is, except for two cases. The debugger will give precedence to assembly level attributes which are defined in an assembly named autoexp.dll and placed in one of the following two locations

  1. Visualizers folder for the current user. One my machine it is C:\Users\jaredp\Documents\Visual Studio 2008\Visualizers
  2. Devenv global visualizer folder. C:\Program Files\Microsoft Visual Studio 9.0\Common7\Packages\Debugger\Visualizers\Original

If you navigate to either of these directories you will find both the default autoexp.dll and the source code used to compile it. It's got quite a few entries you may want to add in a modified version. Adding a new ListDebugView<T> here is possible but lets do it in F# instead.  

Since autoexp.dll has predecence all we need to do is build a new version which has the appropriate debugger attributes for the F# collections. Fire up a new class library project named autoexp and have it output to either of the directories listed above. Below is a sample definition to get you started.

``` fsharp
#light
open System.Diagnostics

module Main =
    type ListProxy<'a>(l:List<'a>) =
        [<DebuggerBrowsableAttribute(DebuggerBrowsableState.RootHidden)>]
        member this.Items = 
            Array.of_list l
            
    [<assembly: DebuggerDisplayAttribute("{Length}", Target=typeof<List<int>>)>]
    [<assembly: DebuggerTypeProxyAttribute(typeof<ListProxy<int>>, Target=typeof<List<int>>)>]
    do 
        ()
```
            

Don't be alarmed at the typeof<List<int>>. The visualizer will work for any generic binding of List<T>. In fact, reflector confirms that this attribute will be emitted with the type pointing at the unbound List<T> instead of List<int>. My lack of F# skills is failing me as to why. I'd love to cry bug but I've found crying bug at a compiler is usually ... wrong.

In either case, once you build this and place in the appropriate folder, you should find the visualizations for List<> much more accessible.

![image](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/DebuggingFlists_129AA/image_thumb_1.png)


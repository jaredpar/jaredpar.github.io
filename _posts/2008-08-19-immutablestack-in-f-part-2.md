---
layout: post
---
I'm a bit busier than I thought I would be after returning from vacation. But I had a little bit of time to play around with the implementation again today.  Thanks to all the suggestions in the comments from the [previous post]({% post_url 2008-08-15-immutablestack-in-f %}).

This version has a couple of improvements including

  1. Removing the ambiguous constructor
  2. More efficient All() implementation

Remaining issues:

  * Need to make it generic :)
  * Still exposing a type union. Great for F# but it produces somewhat awkward looking metadata for non-F# languages to consume

{% highlight fsharp %}
#light

namespace Col  
   type ImmutableStack =  
       | EmptyStack  
       | Value of int * ImmutableStack  
       static member Empty = EmptyStack  
       static member Create( l:#seq<int> ) =  
         let s = ref ImmutableStack.Empty  
         l |> Seq.iter (fun n -> s := (!s).Push(n) )  
         !s  
       member x.Count =  
         let rec count t (cur:ImmutableStack) =  
           match cur.IsEmpty with  
               | true -> t  
               | false -> count (t+1) (cur.Pop())  
         count 0 x  
       member x.IsEmpty =  
         match x with  
           | EmptyStack -> true  
           | _ -> false  
       member x.Push(y) = Value(y,x)  
       member x.Peek() =  
         match x with  
           | EmptyStack -> failwith "ImmutableStack is empty"  
           | Value (v,_) -> v  
       member x.Pop() =  
         match x with  
           | EmptyStack -> failwith "ImmutableStack is empty"  
           | Value (_,n) -> n  
       member x.Reverse() =  
         let rec doBuild (cur:ImmutableStack) (building:ImmutableStack) =  
           match cur.IsEmpty with  
               | true -> building  
               | false -> doBuild (cur.Pop()) (building.Push(cur.Peek()))  
         doBuild x ImmutableStack.Empty  
       member x.All() =  
         match x with  
           | EmptyStack-> Seq.empty<int>  
           | Value (v,n) -> seq {  
               yield v  
               yield! n.All() }
{% endhighlight %}


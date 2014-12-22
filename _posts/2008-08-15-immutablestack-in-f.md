---
layout: post
---
When learning a [new language]({% post_url 2008-08-14-learning-a-new-language-f %}) I find it very instructive to re-code certain structures from my well used libraries into the new language. It gives a great basis for comparison in terms of ease of implementation, expressiveness of the language and sheer ease of implementation. So on that note I set out today to build an ImmutableStack implementation in F#. This is based off of my C# implementation in [RantPack](http://code.msdn.com/rantpack).  

Below is the initial implementation. This is my first non "hello world" data structure in F#. I found it surprisingly easy to implement and I'm really enjoying the language. The biggest stumbling block was getting the type union correct and dealing with my compulsion to use "null" for end of stack instead of a value.

After playing around with it a bit I'm left with the following questions/hangups. Most of these will just fall into the category of "I'm starting out with a new language so I'm still hung up on the syntax in places."

  1. I consider Node to be an implementation detail and ideally would like to make it a private nested class if possible
  2. The constructor still allows for invalid data combinations (but will throw)
    1. Ex: ImmutableStack None ImmutableStack.Empty()
  3. Can I get ImmutableStack.Empty to be a property instead of a function?
  4. In All(), that can't be the most efficient way to build up a sequence.
    
    
``` fsharp
#light

type Node = 
    | Empty
    | Value of int * ImmutableStack

and ImmutableStack(?v:int, ?n:ImmutableStack) = 
    let data = match (v,n) with
                | (Some v, Some n ) -> Value (v,n)
                | (Some v, None) -> Value (v,ImmutableStack.Empty())
                | (None, None) -> Empty
                | _ -> failwith "invalid combination"
    static member Empty() = ImmutableStack()
    member x.IsEmpty() = 
        match data with
            | Empty -> true
            | _ -> false
    member x.Push(y) =
        match data with 
            | Empty -> ImmutableStack(y, x)
            | Value _ -> ImmutableStack(y, x)
    member x.Peek() =
        match data with
            | Empty -> failwith "ImmutableStack is empty"
            | Value (v,_) -> v
    member x.Pop() =
        match data with 
            | Empty -> failwith "ImmutableStack is empty"
            | Value (_,n) -> n
    member x.All() =
        match data with 
            | Empty -> Seq.empty
            | Value (v,n) -> Seq.append (Seq.singleton v) (n.All())
            
let rec printStack (s:ImmutableStack) =
    match s.IsEmpty() with
        | true -> printfn "Empty"
        | false -> 
            printfn "%d" (s.Peek())
            printStack (s.Pop())

let s1 = ImmutableStack.Empty()
let s2 = s1.Push(42).Push(56).Push(62)
let s3 = ImmutableStack 42
let s4 = s3.Pop()

printStack s1
printStack s2
printStack s3
printStack s4
```


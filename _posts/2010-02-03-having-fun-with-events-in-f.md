---
layout: post
title: Having Fun with Events in F#
---
Recently I ran into a situation where I needed to handle some events in F# in a special way. In this particular case I wanted to be able to disable and re- enable my handler based on changes in the program. Essentially the C# equivalent of continually adding and removing the handlers.

I started by using the F# Observable pattern. Disposing of the handler when I was through with it and recreating it on demand. This works great but after several uses I decided to write a full abstraction for it.'? For lack of a better name I call it ToggleHandler.

    
{% highlight fsharp %}
[<AbstractClass>]
type internal ToggleHandler() =
    abstract IsHandling : bool
    abstract Add : unit -> unit
    abstract Remove : unit -> unit
   
    static member Create<'T> (source:System.IObservable<'T>) (func: 'T -> unit) = ToggleHandler<'T>(source,func)
    static member Empty = 
        { new ToggleHandler() with 
            member x.Add() = ()
            member x.Remove() = () 
            member x.IsHandling = false }

and internal ToggleHandler<'T> 
    ( 
        _source : System.IObservable<'T>,
        _func : 'T -> unit) =  
    inherit ToggleHandler()
    let mutable _handler : System.IDisposable option = None
    override x.IsHandling = Option.isSome _handler
    override x.Add() = 
        match _handler with
        | Some(_) -> failwith "Already subcribed"
        | None -> _handler <- _source |> Observable.subscribe _func |> Option.Some
    override x.Remove() =
        match _handler with
        | Some(actual) -> 
            actual.Dispose()
            _handler <- None
        | None -> ()
{% endhighlight %}

The design goal was to support my standard pattern for consuming events.  Typically I store all event handlers as let bindings within a type but the actual delegate handling the event is bound to a member. Member declarations are not available in let bindings so creating an event handler becomes a 2 step process: defining in the let binding and then actually creating inside of a do binding. ToggleHandler facilitates this by providing a very easy let binding story.

    
{% highlight fsharp %}
let mutable _clickHandler = ToggleHandler.Empty
{% endhighlight %}

The base class ToggleHandler is type independent so this will work for any event type. Creating the real binding inside of the initial do binding is likewise as easy (and lacking explicit types).

{% highlight fsharp %}
do
    _clickHandler <- ToggleHandler.Create _button.Click this.OnButtonClick
    _clickHandler.Add()
{% endhighlight %}

Now I can toggle my event handler at any point in the application by calling Add/Remove.

Full Sample:
    
{% highlight fsharp %}
    type Form1() as this =
        inherit Form()
    
        let _button = new Button()
        let mutable _clickHandler = ToggleHandler.Empty
    
        do
            _clickHandler <- ToggleHandler.Create _button.Click this.OnButtonClick
            _clickHandler.Add()
    
        member private x.OnButtonClick (e:System.EventArgs) = 
            // Handle Click 
            ()
    
        member private x.ToggleHandler() =  
            if _clickHandler.IsHandling then _clickHandler.Remove()
            else _clickHandler.Add()
{% endhighlight %}



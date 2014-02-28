---
layout: post
---
Herb Sutter gave one of my favorite and inspiring presentations.?? It is called
"The Free Lunch is Over".?? The original article can be found
[here](http://www.gotw.ca/publications/concurrency-ddj.htm).?? My first
encounter though came from his [PDC presentation](http://www.pluralsight.com/b
logs/hsutter/archive/2005/10/25/15903.aspx) and highly recommend viewing that
as well.

The part that interested me the most about the talk was two new threading
abstractions I hadn't encountered before.?? Future's and ActiveObjects.?? One of
the basic premise is that concurrency should be grep`able and somewhat
declarative.?? The act of calling a method on a background thread and later
waiting for it to complete should be simple, not complicated.

Asynchronous programming is one of my favorite aspects of computing.?? What
interests me the most is how asynchronous programming can be useful for UI.
My biggest pet peeve is when UI hangs because an operation call, or network
operation takes too long.?? Why not make multi-threading easy and give users a
way to cancel out of these operations????? Or start loading on the background
thread instead of waiting for the user to perform a specific.?? Hopefully over
the next month or so I'll lay out some utilities and classes building on
Futures and Active Objects that will do precisely this.

Future's are actions where work can be done now, but the result is not needed
until a future time.?? Work occurs on a separate thread and the results can be
easily joined once work is complete.

    
    
                var f = Future.Create(() => LongCalculation());


                // ...


                var result = f.Wait();

Future's are now exposed via the [Parallel
Extension](http://blogs.msdn.com/pfxteam/archive/2007/11/29/6558413.aspx)
team's work.?? You can download the CTP off of their web site and get to work.

ActiveObjects are objects which only expose Asynchronous functions where the
return value is exposed as a Future.?? So instead of

    
    
            string GetName()

You would have

    
    
            Future<string> GetName()

An ActiveObject essentially lives on or owns a thread.?? All operations are
queued up and processed one at a time.?? Since only one action at a time can be
executing the object internals don't have to use locks or consider many types
of race conditions.?? In fact if your return types are immutable a great many
threading concerns go out the window.?? Yet all of the calls are inherently
asynchronous so callers can get the result only when they are needed.?? The
best of both worlds.

Both of these provide significant advantages over the "lock before use"
patterns.?? In my experience I find these to be hard to maintain and lead to
difficult to track down bugs.?? I can't tell you how many times I've gone
through someone else's code, or even my own, and wondered ...

  * Did they forget to lock here or is this an optimization?
  * Is a join needed here or can these terminate at separate times?
  * OK I need to touch that variable, can it be accessed in multiple threads or is it safe? 

Futures/Active Objects on the other hand are a bit more declarative and
straight forward to understand than plain old locks.?? They allow you to do
away with many uses of plain old locking.?? Don't confuse this with me saying
they are a cure all for threading.?? They're not.?? But in my experiences I've
found them to be a significant upgrade.

Over the next month or so I'll be laying out the design for a basic
ActiveObject implementation.?? We will likely have to deviate off of the
Parrallel Extension work to get certain behaviors but the concepts map well.


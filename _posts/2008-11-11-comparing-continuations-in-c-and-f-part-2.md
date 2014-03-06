---
layout: post
---
In my last post I went over the differences between using a [continuation in F# and C#](http://blogs.msdn.com/jaredpar/archive/2008/11/10/comparing-continuations-in-f-and-c.aspx).  As it turns out I was right about the limits and symptoms but wrong about the reason.

The F# code does indeed generate tail calls for part of the continuation.  However this is only a very small portion of the actual code and is in fact only generated for the call in the empty case.  I misread this function to be the call for the overall continuation.  Instead it is the function for the entire 'inner' lambda.

So why does F# perform differently than C# in this scenario?

Andrew Kennedy pointed out that F# will actually transform the 'inner' function into a loop.  In affect the code generated looks like the following.

{% highlight csharp %}
TypeFunc func = this._self3;
while (true)
{
    if (!this.e.MoveNext())
    {
        break;
    }
    A cur = this.e.Current;
    cont = new Program.clo@9<U V, A ,>(this.combine, cont, cur);
}
return cont.Invoke(this.acc);
{% endhighlight %}

The actual transformation into a loop is what is preventing F# from overflowing the stack here.  Iteration incurs no stack overhead in this case.

Even more interesting is that the [tail opcode](http://msdn.microsoft.com/en-us/library/system.reflection.emit.opcodes.tailcall\(VS.71\).aspx) is quite simply ignored when dealing with un-trusted code.  It therefore cannot be relied on to generate performant code in all scenarios.

_


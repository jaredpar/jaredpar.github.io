---
layout: post
---
Is it better to be wrong once or to be right then think you're wrong but find out you were right but wrong about being wrong? Besides the obvious be right the first time, it's certainly an educational experience.  

Here's the original sample:
    
{% highlight fsharp %}
let FoldRight combine (sequence:seq<'a>) acc = 
    use e = sequence.GetEnumerator()
    let rec inner cont = 
        match e.MoveNext() with
            | true -> 
                let cur = e.Current
                inner (fun racc -> cont (combine cur racc))
            | false -> cont acc
    inner (fun x -> x )
{% endhighlight %}

[Brian McNamara](http://lorgonblog.spaces.live.com/blog/) pointed out I wasn't considering all of the call sites for this sample. In addition to the recursive call to 'inner' and the initial inner call, there is the actual recursive invocation of the of the continuations. Effectively the 'inner' function is building up a list of list of lambdas which call the combine function. The output of the combine function is simply passed into the next lambda in the list. The last lambda in the list is the identity lambda and returns the final call to combine. This value is the actual value returned from the initial invocation 'cont acc'. Lambdas are methods under the hood.  Without a tail instruction, this chain of lambda calls will just as easily overflow the stack.

Digging deeper into the compiled F# code we can view this call and indeed it is done with tail recursion.

    .method public virtual instance !V Invoke(!U racc) cil managed
    {
        .maxstack 8
        L_0000: nop 
        L_0001: ldarg.0 
        L_0002: ldfld class [FSharp.Core]Microsoft.FSharp.Core.FastFunc`2 Program/clo@9::cont
        L_0007: ldarg.0 
        L_0008: ldfld class [FSharp.Core]Microsoft.FSharp.Core.FastFunc`2> Program/clo@9::combine
        L_000d: ldarg.0 
        L_000e: ldfld !2 Program/clo@9::cur
        L_0013: ldarg.1 
        L_0014: call !!0 [FSharp.Core]Microsoft.FSharp.Core.FastFunc`2::InvokeFast2(class [FSharp.Core]Microsoft.FSharp.Core.FastFunc`2>, !0, !1)
        L_0019: tail 
        L_001b: callvirt instance !1 [FSharp.Core]Microsoft.FSharp.Core.FastFunc`2::Invoke(!0)
        L_0020: ret 
    }

The below code more accurately resembles the equivalent C# code that is generated for the above F# sample?? (thanks Brian!).

{% highlight csharp %}
public static TAcc Inner<TSource, TAcc>(
    this IEnumerator<TSource> e,
    Func<TAcc, TSource, TAcc> combine,
    TAcc start,
    Func<TAcc, TAcc> cont)
{
    while (e.MoveNext())
    {
        var cur = e.Current;
        Func<TAcc, TAcc> innerCont = cont;
        cont = (x) => /*need .tail here */innerCont(combine(x, cur));
    }
    return cont(start);
}

public static TAcc FoldRight<TSource, TAcc>(
    this IEnumerable<TSource> enumerable,
    Func<TAcc, TSource, TAcc> combine,
    TAcc start)
{
    using (var e = enumerable.GetEnumerator())
    {
        return Inner(e, combine, start, (x) => x);
    }
}
{% endhighlight %}

**Previous Entries**

  * [Part 1](http://blogs.msdn.com/jaredpar/archive/2008/11/10/comparing-continuations-in-f-and-c.aspx)
  * [Part 2](http://blogs.msdn.com/jaredpar/archive/2008/11/11/comparing-continuations-in-c-and-f-part-2.aspx)


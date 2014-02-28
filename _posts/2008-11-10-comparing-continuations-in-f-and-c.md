---
layout: post
---
Lately I???ve been playing quite a bit with F#.?? I have several hobby projects
I???m working on that take up a bit of my time.?? But when I???m not playing around
with F# I???m exploring ways to apply certain functional patterns to actual
coding on the job and/or porting to my functional library:
[RantPack](http://code.msdn.microsoft.com/RantPack).

Recently I???ve been playing around with continuations in F#.?? I thought this
was a great topic to do a F# comparison with other languages.?? In this case
C#.

Let???s examine a classic use of continuations: a right fold on a list.?? For a
detailed explanation of fold right and the use of a continuation I suggest
taking a look at [Brian's discussion](http://lorgonblog.spaces.live.com/blog/c
ns!701679AD17B6D310!170.entry).?? If you???re unfamiliar with continuations I
highly suggest that you take a look at this post as Brian gives a great
breakdown of continuations and their uses.

Here's a quick refresher on continuations by example.?? Fold right is an
operation which reduces a sequence of elements into a single element by
processing the list from right to left.?? It???s similar to the [LINQ
Aggregate](http://msdn.microsoft.com/en-
us/library/system.linq.enumerable.aggregate.aspx) method except Aggregate
operations left to right.

For this post we???ll be writing FoldRight against a sequence.?? I chose sequence
vs. the traditional list because it???s present in both languages (F# = seq<???a>,
C# = IEnumerable<T>).?? It is possible to other F# data structures in C# but
the comparison is cleaner when using a type that is native to both languages.

Sequences are a left to right data structure so processing it right to left is
not natural.?? After all, with a sequence all the developer has is current and
whether or not there is a next element.?? Processing the list in a right to
left fashion can be done by such acts as reversing the list, or doing a head
recursive call.?? Both have their detractors.

Continuations are a different way to process the list.?? Instead of processing
the list directly we process the list a single element at a time building up a
continuation along the way.?? For each element a lambda expression is generated
representing the work needed to be done for that element.?? The value
calculated within the lambda will then be passed to the lambda calculated for
the previous element.?? Once we hit the end of the list, we essentially have a
chain of lambda expressions which process each element in the list in reverse
order.?? All that is needed is to call the final lambda with the starting value
and we will effectively process the list in reverse order.

Simple enough??? Lets take a look at the code.

**F# Code**
    
    
    let FoldRight combine (sequence:seq<'a>) acc = 


        use e = sequence.GetEnumerator()


        let rec inner cont = 


            match e.MoveNext() with


                | true -> 


                    let cur = e.Current


                    inner (fun racc -> cont (combine cur racc))


                | false -> cont acc


        inner (fun x -> x )

**C# Code**??
    
    
    public static TAcc FoldRight<TSource, TAcc>(


        this IEnumerable<TSource> enumerable, 


        Func<TAcc, TSource, TAcc> combine, 


        TAcc start) {


    


        using (var e = enumerable.GetEnumerator()) {


            Func<Func<TAcc, TAcc>, TAcc> inner = null;


            inner = (cont) => {


                  if (e.MoveNext()) {


                      var cur = e.Current;


                      Func<TAcc, TAcc> innerCont = (x) => cont(combine(x, cur));


                      return inner(innerCont);


                  } else {


                      return cont(start);


                  }


              };


            return inner(x => x);


        }


    }

My immediate reaction to the two samples is the conciseness of the F# code.
This is a not a criticism of C# though.?? F# is designed to be a concise
language and it???s delivery on that goal is evident in this sample.

What makes the big difference here is the type inference power of F#.?? In the
C# sample there are 6 explicit types listed in the code sample.?? The F# sample
only has a single type listed.?? The compiler is able to infer and/or generate
the rest of the signatures.?? F# also requires less explicit generic parameters
1 vs. 2 in C#.

The next big difference I see is the awkward way in which the inner lambda
expression must be declared in C#.?? The lambda expression is called
recursively in order to setup the continuation.?? In order to do that in C# the
lambda must be declared and defined in separate expressions.?? Otherwise, a
self reference of ???inner??? inside the body of ???inner??? will generate a used
before defined warning from the compiler.

**The IL**

Examining the full IL of both functions would take several blog posts.?? Not to
mention that trying to read disassembled F# much less IL, is like trying to
read disassembled C++.?? An interesting exercise but a bit time consuming.

I did want to focus a bit on one portion of the generated IL.?? There is a very
significant difference in the way the recursive call to the ???inner??? lambda is
made.

F#

    
    
        L_0032: ldarg.1 


        L_0033: ldarg.0 


        L_0034: ldfld !0 Test/clo@6T::acc


        L_0039: tail 


        L_003b: callvirt instance !1 [FSharp.Core]Microsoft.FSharp.Core.FastFunc`2::Invoke(!0)

C#

    
    
        


        L_0077: ldarg.0 


        L_0078: ldfld class [System.Core]System.Func`2, !1> ConsoleApplication1.Extensions/<>c__DisplayClass8::inner


        L_007d: ldloc.0 


        L_007e: callvirt instance !1 [System.Core]System.Func`2, !TAcc>::Invoke(!0)


        L_0083: stloc.3 

In both cases the first 3 lines are building up the 2 parameters necessary for
the recursive lambda call.?? The closures are structured somewhat differently
but the same basic operation is being done.

The key difference between the languages is F#???s use of the [tail
opcode](http://msdn.microsoft.com/en-
us/library/system.reflection.emit.opcodes.tailcall\(VS.95\).aspx).?? This
opcode tells the CLR the to call the next method in a tail recursive fashion.
This causes the CLR to remove the current method frame from the stack before
the next method is called.?? Because the method is removed from the stack, the
recursive call takes up no additional stack space.?? This is true no matter how
many times the function is called.

The C# IL does not have this opcode.?? So the recursive call will happen with
the current method on the frame.?? With a big enough sequence this will cause
the process to run out of stack space and generate a StackOverflowException.
This creates a limitation on the number of elements the C# sample can process.

**Limits**

I explored the limits of both samples on my home laptop.?? I generated a simple
example to sum the sequence with the fold right.?? Note: For a sum of ints, a
fold left is just as good, but it serves fine for this sample.

F#

    
    
    let sum = FoldRight (fun x y -> x + y) [1..1000000] 0


    printfn "%d" sum

C#

    
    
    var source = Enumerable.Range(1, 9397);


    var result = source.FoldRight((x, y) => x + y, 0);


    Console.WriteLine("{0}", result);

The C# sample can process a maximum size of 9397 elements.?? After that I
encounter a stackoverflow exception. The F# sample however can easily process
1,000,000 elements.

Closing note.?? This not meant to be a post criticizing C#.?? It???s meant to be a
general comparison of the same technique in two managed languages.?? This is a
scenario that is far less likely to occur in a C# program.?? In an F# program
it???s quite simply an expectation and hence the F# compiler is optimized for
this scenario.


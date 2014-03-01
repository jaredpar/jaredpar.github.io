---
layout: post
---

During a review of some low level bit manipulation logic a developer raised a
question about the correctness of a piece of code which allowed any arbitrary
byte to be seen as a bool. No one could recall if true was defined as not 0
or simply 1. If it was the latter then the code was allowing for a large
range of invalid bool values to be created. A quick look at the CLI spec
revealed the immediate answer (partition III section 1.1.2)

> A CLI Boolean type occupies 1 byte in memory. A bit pattern of all zeroes
denotes a value of false. A bit pattern with any one or more bits set
(analogous to a non-zero integer) denotes a value of true.

A quick test backed up this particular assertion. Any non-zero value is true
and 0 is indeed false. We took the test one step further and discovered, to
the surprise of about half of us, that just because two bool values are true,
doesn't mean they're equal.

{% highlight csharp %}
class Program
{
    [StructLayout(LayoutKind.Explicit)]
    struct Union
    {
        [FieldOffset(0)]
        internal byte ByteField;

        [FieldOffset(0)]
        internal bool BoolField;
    }

    static void Main(string[] args)
    {
        Union u1 = new Union();
        Union u2 = new Union();
        u1.ByteField = 1;
        u2.ByteField = 2;
        Console.WriteLine(u1.BoolField); // True
        Console.WriteLine(u2.BoolField); // True
        Console.WriteLine(u1.BoolField == u2.BoolField); // False
    }
}
{% endhighlight %}

I was one of those who was surprised! :) 


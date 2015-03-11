---
layout: post
title: Observing a null this value
tags: [c#]
---
One of my favorite bits of .NET trivia is whether or not it is possible to observe a `null` value for `this`?  Most developers I ask either say no, or yes but it requires incorrect IL / unsafe code.  Since I'm writing this post you can probably guess that the answer is actually yes, `this` can indeed be `null`.

To demonstrate this behavior let's start with a simple command line application:

``` csharp
class Program
{
    void Test()
    {
        if (this == null)
            Console.WriteLine("this is null");
    }

    static void Main(string[] args)
    {
        Program p = null;
        p.Test();
    }
}
```

No tricks here.  Compiling and running this program will result in a `NullReferenceException` on the `p.Test` call exactly as a developer would expect.  But how is this exception being generated?  Lets take a look at the IL for this particular call using ildasm. 

``` 
IL_0003:  ldloc.0
IL_0004:  callvirt   instance void NullThis.Program::Test()
```

The `Test` method is being invoked via the [callvirt](https://msdn.microsoft.com/en-us/library/system.reflection.emit.opcodes.callvirt%28v=vs.110%29.aspx?f=255&MSPPError=-2147217396) instruction.  This performs a virtual dispatch of the target method.  Part of the contract for this instructions is to throw a `NullReferenceException` if the target object, in this case `p`, is `null`.  Hence this is the source of the exception.  

But is callvirt necessary here?  This is a non-virtual method so surely the virtual dispatch is unnecessary overhead.  Let's fix that by changing the instruction to [call](https://msdn.microsoft.com/en-us/library/system.reflection.emit.opcodes.call(v=vs.110).aspx).  

``` 
IL_0003:  ldloc.0
IL_0004:  call   instance void NullThis.Program::Test()
```

The new IL is legal and PEVerify clean.  But what happens if we pass this through ilasm and run the resulting program? 

``` text
$>ilasm /out:NullThis.exe /quiet NullThis.il 
$>NullThis.exe
this is null
```

Viola, our program has observed a `null` value for `this`.  

The reason for the behavior change is the call instruction simply does not check for null as does callvirt.  It passes along the target object as `this` without any inspection.  This is one of the reasons why languages like C# will emit a callvirt instruction even for non-virtual methods.  It serves as a cheap way of doing a `null` check on the target object.  

Now after reading this some developers might wonder if they should start adding `null` checks for `this` to their code?  No, please don't.  The standard .Net compilers (C#, VB, F#, etc ...) will not emit IL that can observe a `null` value for `this`.  Observing this behavior requires either hand crafting IL, using C++/CLI tricks or tricks with PInvoke and unsafe code.  Not a situation that the majority of .NET applications out there will encounter. 


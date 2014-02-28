---
layout: post
---
The short answer is: No, not when it matters

A colleague and I were discussing a particular scenario around IntPtr,PInvoke
and 64 bit correctness.?? Eventually our discussion lead us to the IntPtr
constructor which takes a long.?? To my surprise the code for the constructor
is the following.

public unsafe **[IntPtr](http://www.aisto.com/roeder/dotnet/Default.aspx?Targe
t=code://mscorlib:2.0.0.0:b77a5c561934e089/System.IntPtr/.ctor\(Int64\))**([lo
ng](http://www.aisto.com/roeder/dotnet/Default.aspx?Target=code://mscorlib:2.0
.0.0:b77a5c561934e089/System.Int64) value) { this.[m_value](http://www.aisto.c
om/roeder/dotnet/Default.aspx?Target=code://mscorlib:2.0.0.0:b77a5c561934e089/
System.IntPtr/m_value:Void*) = ([void](http://www.aisto.com/roeder/dotnet/Defa
ult.aspx?Target=code://mscorlib:2.0.0.0:b77a5c561934e089/System.Void)*) (([int
](http://www.aisto.com/roeder/dotnet/Default.aspx?Target=code://mscorlib:2.0.0
.0:b77a5c561934e089/System.Int32)) value); }

The problem is long value is arbitrarily truncated to an int.?? This has the
effect of essentially losing any address over the 4 GB range (in other words,
no 64 bit addresses).?? This much to big of a hole to actually be the real
behavior so I decided to see if it was a bug in the disassembler.?? I was using
.Net Reflector so I switched to IL mode.

    
    
        L_0000: ldarg.0 


        L_0001: ldarg.1 


        L_0002: conv.ovf.i4 


        L_0003: conv.i 


        L_0004: stfld void* System.IntPtr::m_value


        L_0009: ret 

This confirmed it is indeed truncating the value (and doing an overflow check
to boot). But wait, mscorlib.dll is a processor specific DLL so perhaps this
is just a 32 bit OS thing.?? I switched over to a 64 bit machine, fired up
Reflctor and found to my dismay that it had the exact same code.

After a few minutes I thought to open up task manager and to my surprise
reflector was running in a WoW64 bit process.?? This meant it was still loading
up the 32 bit version of mscorlib.dll.?? Next I fired up ildasm, loaded up a 64
bit mscorlib and confirmed that the code will not truncate on 64 bit machines.

    
    
      IL_0000:  ldarg.0


      IL_0001:  ldarg.1


      IL_0002:  conv.u


      IL_0003:  stfld      void* System.IntPtr::m_value


      IL_0008:  ret

The conv.u code is a conversion to unsigned native platform int. On a 64 bit
machine this will be an unsigned 8 byte number(see
[OpCodes.Conv_U](http://msdn.microsoft.com/en-
us/library/system.reflection.emit.opcodes.conv_u.aspx) for more details).

So what does this mean for the developer.?? Essentially IntPtr(long) will do
the right thing independently of the platform a developer is using.?? On a 32
bit platform it will (correctly) throw exceptions if a non-4GB address is
passed in.?? In 64 bit land it will essentially do nothing and rely on the
programmer to give correct addresses.


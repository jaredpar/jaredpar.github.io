---
layout: post
---
Debugging PowerShell can be extremely frustrating because it often turns into
a session of debugging your own thought process.  Often when I hit a
PowerShell script issue I find myself feeling like everything is right and I'm
just missing something basic.  IMHO, this is because I spend the majority of
my day programming in compiled languages and don't completely come out of that
box when I'm programming in PowerShell.

For instance the other day I added one of Lee Holme's scripts to my default
profile.  The script is used to create a Generic object inside of PowerShell.

<http://www.leeholmes.com/blog/CreatingGenericTypesInPowerShell.aspx>

The syntax is very clean.  It is the same as new-object but requires the
additional type parameters.

    
    
    $PS>new-genericobject Collections.Generic.List int


    $PS>


    

The only problem was I couldn't get the script to return an object.  I tried a
couple of operations like passing the output to get-member and seeing what
exactly I was creating.  I kept getting errors like "No object has been
specified ...".  My mind kept saying "It's there, it's non-null, why doesn't
it have any members!!!".

Frustrated I turned to some internal aliases and eventually Lee helped me out.
Nothing above is in error.  The problem is PowerShell will unroll collection
classes.  In this case I've created an empty collection so there is nothing to
output or pass to get-member.   My issues is that I kept thinking it terms of
compiled languages instead of PowerShell's collection unrolling semantics
(which I will add, I quite like).

Sadly any other object creating would have quickly lead me to this solution

    
    
    C:\Users\jaredpar\winconfig\PowerShell> new-genericobject collections.generic.Ke


    yValuePair int,int


    


                                        Key                                   Value


                                        ---                                   -----


                                          0                                       0


    

Another way to figure out this problem would be to bypass the collection
unrolling in pipelines and directly specify the object to get-member.

    
    
    C:\Users\jaredpar\winconfig\PowerShell> gm -inputobject $col


    


    


       TypeName: System.Collections.Generic.List`1[[System.Int32, mscorlib, Version


    =2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]


    ...


    


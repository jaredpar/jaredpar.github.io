---
layout: post
---
Multi-targeting is a feature introduced in Visual Studio 2008 which allows
developers to use new versions of Visual Studio to target earlier versions of
the .Net platform. It allowed users to target both the new 3.5 and 3.0 and
the previous 2.0 profile with the same IDE. Visual Studio 2010 [continues
this trend](http://msdn.microsoft.com/en-us/magazine/ff714560.aspx) by adding
support for CLR 4.0 and even allows for further sub-targeting through several
[framework profiles](http://channel9.msdn.com/posts/funkyonex/Multi-Targeting-
Deep-Dive-with-Visual-Basic-2010/).

At a compiler level this works by providing binary compatibility with previous
versions of the CLR (or producing an error when it's not possible). It
doesn't warn developers about using new language constructs on older
frameworks so long as they function in the target framework.

Take the following code sample as an example. It is taking advantage of
[implicit line
continuations](http://blogs.msdn.com/b/vbteam/archive/2009/03/27/implicit-
line-continuation-in-vb-10-tyler-whitney.aspx) which is a feature introduced
in VB.Net 10 and not available in Visual Studio 2008. Since it's just
syntactic sugar it compiles just fine in an application targeting 4.0 or any
previous version of the framework.

    
    
    Dim query =


        From it In col


        Where it Mod 2 = 0


        Select it * 3

In a limited set of scenarios though developers want to use Visual Studio 2010
to develop code which will also be compiled by a previous version of the
compiler. Hence they want warnings in Visual Studio when new language
constructs are used.

The 10.0 version of vbc.exe introduced a new switch named
[langversion](http://msdn.microsoft.com/en-us/library/dd547577.aspx) to
provide just that. It allows developers to specify a version of the language
to target. The compiler will then issue an error when a language construct
which was introduced in a later version is used. This switch is not available
from the IDE though and must be manually specified in the project file. To do
so edit the .vbproj file and add the following element under the main
ItemGroup element.

    
    
      <PropertyGroup>


        <LangVersion>9</LangVersion>


      </PropertyGroup>


    


    

Once the project is reloaded errors will start appearing for new language
constructs. Notice how our earlier sample now produces the errors for the
usages of the new implicit line continuation construct.

![image](http://blogs.msdn.com/cfs-file.ashx/__key/CommunityServer-Blogs-
Components-
WeblogFiles/00-00-00-39-97-metablogapi/3173.image_5F00_thumb_5F00_1.png)


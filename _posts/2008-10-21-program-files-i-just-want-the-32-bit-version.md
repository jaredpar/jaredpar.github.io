---
layout: post
---
As part of my [transition]({% post_url 2008-10-16-powershell-and-64-bit-windows-helper-functions %}) into using 64 bit windows I keep running into a problem with some scripts.  

I have a whole set of Powershell scripts that are dedicated to ensuring certain programs are installed on all of my dev machines. Or that certain customizations are needed. A lot of these do file existence checks inside of Program Files.

Unfortunately in 64 bit windows there are actually two Program Files folders.  One for 64 bit programs and a separate one for 32 bit programs that operate in Wow64 mode. All code which uses $env:ProgramFiles will point to the 64 bit version. Most of the programs I custom install (i.e. gvim are actually 32 bit programs).

Getting the 32 bit Program Files directory is simple enough: ${env:ProgramFiles(x86)}. Yet it's not portable back to a 32 bit version of windows. Yet another function to the rescue

{% highlight powershell %}
function Get-ProgramFiles32() {
    if (Test-Win64 ) {
        return ${env:ProgramFiles(x86)}
    }
    
    return $env:ProgramFiles
}
{% endhighlight %}


---
layout: post
---
I often delete versioned files from Visual Studio without great care for the source control impact.  However I eventually have to go through and clean up the mess I made by not properly deleting the files from svn as well as on disk.  When you delete a file physically but not in SVN, SVN willl declare the file missing.

For a couple of files a quick "svn delete foo.txt" will take care of the problem.  When there are lots of files this is tedious and prone to error.  That is, unless you have powershell.

{% highlight powershell %}
# Used to do a "svn delete" on all missing files  
function SvnRemoveMissing()  
{  
    $data = & svn status  
    foreach ( $entry in $data )  
    {  
        if ( $entry -match "^!\s+(.*)$" )  
        {  
            & svn delete $($matches[1])  
        }  
    }  
}  
{% endhighlight %}


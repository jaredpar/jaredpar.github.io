---
layout: post
---
If you've ever been debugging a managed app, only to be unable to evaluate any of the locals or parameters because the code was "optimized", check out the article below. It shows a quick trick to disable optimizations by way of a .ini file. This is great because it doesn't force you to recompile the application and takes only seconds to implement.

The short version is create an .ini file (i.e. myapp.ini) with the following contents.
    
    [.NET Framework Debugging Control]
    GenerateTrackingInfo=1
    AllowOptimize=0

This has really saved me time debugging recently. It's been blogged about by several others but given that I've had to search for this solution 3 times in as many weeks, I figured blogging about it would make it easier to find next time :)

<http://msdn.microsoft.com/en-us/library/9dd8z24x.aspx>


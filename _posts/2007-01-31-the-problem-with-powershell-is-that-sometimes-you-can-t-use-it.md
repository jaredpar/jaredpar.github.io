---
layout: post
---
PowerShell puts the fun back in scripting and it's horrfying but every now and
again I'm forced to write a good old batch script.  Batch is good enough to
get most jobs done it's just not as "fun" as PowerShell.  Recently it came up
in an internal alias about how to detect if you're running on Vista from a
batch script.

for /f "tokens=4 delims=.] " %%i in ('ver') do set OSVERSION=%%i  

This parses the output of the "ver" command in batch and gives back the
result.  If %OSVERSION% is 6 then you're on Vista.


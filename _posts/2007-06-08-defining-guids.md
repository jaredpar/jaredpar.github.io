---
layout: post
---
One of the tasks I find to be annoying during development is pasting GUID's into my code.  You need GUID's for lots of different functions (COM, Constants, etc ...).  GuidGen is a good tool for getting the Guid into your code.  However I don't insert GUID's very often.  Everytime I do, I find I've forgotten where the tool is.  Then I go through the process of locating it and getting my GUID out.

PowerShell to the rescue :)

    PS> [Guid]::NewGuid().ToString() | out-clipboard

[Edit1] Corrected ToString->ToString() Tom Barnum's feedback.


---
layout: post
---
If you can't tell from reading entries in my blog I'm a bit of a script junkie. I loathe typing out the same command sequence more than once. As such I go to great lengths to script as much as possible in life. I also enjoy sharing my scripts with other members of my team.

Unfortunately deployment of PowerShell scripts has long been a point of pain for me. In the early 1.0 days PowerShell wasn't installed by default on any OS so the only people with PowerShell were other scripter's. Deploying to the masses simply wasn't possible without installing PowerShell which is a significant adoption barrier. Even if PowerShell was installed, the default setup forbids the execution of any script file. Allowing scripts to run in 1.0 requires both Administrative privileges and a rather awkward command sequence: set-executionpolicy RemoteSigned.

These two combined to make it nearly impossible to distribute my scripts to the masses. Other devs, after explanations, understood the problems I encountered. But the masses simply did not. The wanted a quick, one or two click solution to their problem. Running a powershell script was simply too involved.

The best solution I found was to distribute both a .cmd and a .ps1 file. The .cmd file's job was to set the special registry key to allow script execution and then run the script. This still hurt adoption because it required administrative privileges and an existing copy of powershell on the machine.  

Thankfully the story is quite a bit better in 2.0?? The primary improvement is simply adoption. PowerShell is installed by default in Windows7 and certain flavors of W2K8. Windows7 is very popular amongst my coworkers and hence I can depend on at least a PowerShell deployment when I write my scripts.  

The next improvement surrounds the execution of scripts. The default is still to have script execution disabled but you no longer have to be an administrator to do so. Additionally you can specify on the PowerShell command line what the execution policy can be. This mean you can have a script execute without the user having to manually enable script execution.

The command line is still a bit awkward. But it's easily solved by deploying both a .cmd and .ps1 file. The .cmd file simply calls the .ps1 file with the awkward command line. Users are comfortable clicking on a .cmd file and it removes all knowledge of powershell from the equation.

For example:

Fix-Setup.cmd

    set SOURCE=%~dp0
    set TARGET=%SOURCE%\Fix-Setup.ps1
    powershell -ExecutionPolicy RemoteSigned %TARGET%

These small changes greatly increased the adoption rate of scripts within my group.


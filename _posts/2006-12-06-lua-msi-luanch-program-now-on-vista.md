---
layout: post
---
I'm a **huge** fan of the LUA support in Vista.  It has it's quirks but it's a major step forward for Windows programming.  As a former *nix guy I've had to run LUA the hard way before Vista.  The support in Vista is tons better than it used to be.

There are a few areas that are still not optimal.  One of them that's been bugging me lately are legacy MSI installers.  Vista almost always correctly elevates and offers to run the installer as Admin.

This causes a small problem though with some legacy MSI's.  A lot of MSI have a check box at the end of the MSI setup with text similar to "Launch SuchAndSuch Program Now".  The problem is who the program launches as.  

Prior to Vista there was no auto-priviledge elevation.  So most people ran MSI's as there normal user account which was an admin.  Launching the process at the end of the MSI was just fine.

Now in Vista most people run as a normal user and MSI's elevated.  So this feature will now, on legacy MSI's, launch the program as an Administrator rather than your normal user account.

Without the help of a tool, there's no good way to detect when this happens.  To be safe, I always un check that box and manually start the app so I know it will be running under my normal account.


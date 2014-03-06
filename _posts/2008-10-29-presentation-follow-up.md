---
layout: post
---
Thanks to everyone who showed up at the [presentation on monday](http://blogs.msdn.com/jaredpar/archive/2008/10/23/presenting-at-net-developers-association-meeting-oct-27.aspx). For those interested, I've uploaded the contents of the presentation [here](http://cid-dc25b20f65f628f8.skydrive.live.com/self.aspx/Public/Linq%20Presentation).  

I was unable to upload the large DB file used during the demo due to size limitations (sky drive will only let me upload a 50 MB file). But better than wasting both mine and your bandwidth, I included the script used to generate the db file.

The file is a powershell script named GenerateDb.ps1. If you pass the -argLarge switch, it will generate the 120MB demo file.

    PS>.\GenerateDb.ps1 -argLarge


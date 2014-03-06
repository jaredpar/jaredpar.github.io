---
layout: post
---
Recently I needed to filter the return of get-psdrive to return all of my local hard drives.  I didn't want to accidentally start operating on floppies, CDROM's and more importantly, network drives.  There are a couple of ways to do this but I found the most straight forward is to combine the WMI data with get-psdrive.

    E:\temp> get-wmiobject win32_volume | ? { $_.DriveType -eq 3 } | % { get-
    psdrive  
    $_.DriveLetter[0] }

    Name       Provider      Root
    CurrentLocation  
    \----       \--------      \----
    \---------------  
    C          FileSystem    C:\
    ...nfig\PowerShell  
    E          FileSystem    E:\
    temp

DriveType is a property of the Win32_Volume structure which enumerates the type of drive.  The value 3 stands for Local Disk.  Below is the full list of values.

    0 - Unknown  
    1 - No Root Directory  
    2 - Removable Disk  
    3 - Local Disk  
    4 - Network Drive  
    5 - Compact Disk  
    6 - RAM Disk


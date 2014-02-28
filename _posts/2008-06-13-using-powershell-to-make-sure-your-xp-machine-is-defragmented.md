---
layout: post
---
Quick script you can run at login to ensure that your XP machine is being
defragmented.  I chose 1:00 AM every evening but you can quickly alter that in
the script.  I have this script run as part of my regular set of configuration
scripts to ensure that my XP machines are in good shape.  

$script:title = "Xp Regular Degrag"  
if ( 5 -ne [Environment]::OsVersion.Version.Major ) {  
    return;   
}  
$found = schtasks /query | ?{ $_ -match "^\w*$title" } | test-any  
if ( $found ) {  
    return  
}  
# Set up the defrag task  
$task = "{0} {1}" -f (join-path $env:WinDir
"System32\defrag.exe"),$env:SystemDrive  
schtasks /create /ru system /tn $title /sc daily /st "01:00:00" /tr $task


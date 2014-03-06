---
layout: post
---
I've been an avid fan of running as a limited user account (LUA) for almost all of my computing career.  It's in large part a holdover from my *NIX days but it's an important practice for Windows as well. I'm very excited about this being the default for Windows going forward starting with Vista.

The bad news is that not everyone is quite LUA compliant yet.  This hits me hardest with PowerShell when I'm trying to run some auto update scripts that change the Registry.  There are a lot of programs I use that still store their settings in HKLM or the likes.  So I've added a PowerShell script that will grant me access to those keys as an LUA.  It was written a long time ago so it
doesn't utilize the get/set-acl commandlets but it runs just the same.

    # Give the user access to the registry entry
    function GrantLuaRegistryKey([string]$regkeyPath)
    {
    	[string]$ident = "{0}\{1}" -f ${env:\userdomain}, ${env:\username};
    	$rights = [Enum]::Parse([Security.AccessControl.RegistryRights], "FullControl"); 
    	$allow = [Enum]::Parse([Security.AccessControl.AccessControlType], "Allow");
    	$iFlags = [Enum]::Parse([Security.AccessControl.InheritanceFlags], "ContainerInherit,ObjectInherit");
    	$pFlags = [Enum]::Parse([Security.AccessControl.PropagationFlags], "None");
    	$rule = new-object Security.AccessControl.RegistryAccessRule $ident,$rights,$iFlags,$pFlags,$allow;
    	$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($regkeyPath, $true);
    	
    	# Add the rule to the collection
    	$col = $key.GetAccessControl();
    	$col.AddAccessRule($rule);
    	$key.SetAccessControl($col);
    	$key.Close();
    }
    


    


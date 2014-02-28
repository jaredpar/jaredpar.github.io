---
layout: post
---
Here's a handy PowerShell function I used to determine if I'm currently
running as an Administrator in PowerShell

# Determine if I am running as an Admin  
function AmIAdmin()  
{  
 $ident = [Security.Principal.WindowsIdentity]::GetCurrent()  
  
 foreach ( $groupIdent in $ident.Groups )  
 {  
  if ( $groupIdent.IsValidTargetType([Security.Principal.SecurityIdentifier])
)  
  {  
   $groupSid = $groupIdent.Translate([Security.Principal.SecurityIdentifier])  
   if ( $groupSid.IsWellKnown("AccountAdministratorSid") -or
$groupSid.IsWellKnown("BuiltinAdministratorsSid"))  
   {  
    return $true;  
   }  
  }  
 }  
  
 return $false;  
}  


---
layout: post
---
This came up on an internal alias.  A customer wanted to know how to determine if there were running as an admin in a tool.  Below is a sample program that will print out whether or not you are the machine admin or a member of the machine administrators group.

This is essentially the same as the code in a previous post of mine but ported to [VB]({% post_url 2005-11-07-489942 %}).

``` vb
Imports System.Security.Principal
Module Module1

    Function IsRunningAsLocalAdmin() As Boolean
        Dim cur As WindowsIdentity = WindowsIdentity.GetCurrent()
        For Each role As IdentityReference In cur.Groups
            If role.IsValidTargetType(GetType(SecurityIdentifier)) Then
                Dim sid As SecurityIdentifier = DirectCast(role.Translate(GetType(SecurityIdentifier)), SecurityIdentifier)
                If sid.IsWellKnown(WellKnownSidType.AccountAdministratorSid) OrElse sid.IsWellKnown(WellKnownSidType.BuiltinAdministratorsSid) Then
                    Return True
                End If

            End If
        Next

        Return False
    End Function

    Sub Main()
        Console.WriteLine("Is Admin {0}", IsRunningAsLocalAdmin())
    End Sub

End Module
```


    


---
layout: post
---
.Net 2.0 Added a lot in the way of allowing programmers to easily interact
with Windows.  One of the best additions is the Microsoft.Win32.SystemEvents
class.  It holds events for a lot of system relatied events (hence the name).

A common scenario I see on the forums is users wanting to respond to a system
shutown event.  The easiest way to access this from managed code is the
Microsoft.Win32.SystemEvents.SessionEnding event.  This is not exactly the
shutdown event because it actually represents the user session that the
program is running in.  A session is created when you log into the system and
is destroyed when you log off or shutdown the computer (which eventually
forces a logoff :) ).

The arguments provide two pieces of useful information.  The first being the
reason for the session ending (logoff or shutdown).  It also allows you to
cancel the event via the Cancel property.  For example the following code will
prevent the shutdown of the computer as long as the program is running.

    
    
    Imports Microsoft.Win32


    


    Sub PreventShutdown()


      AddHandler SystemEvents.SessionEnding AddressOf PreventShutdownHelper


    End Sub


    


    Sub PreventShutdownHelper(ByVal sender As Object, ByVal args As SessionEndingEventArgs)


      If args.Reason = SessionEndReasons.Shutdown Then


        args.Cancel = True


      End If


    End Sub


    

While this will prevent the shutdown from occurring you will see many of the
apps on your screen close.  That's because some of them get the shutdown event
before your app and most will close as a result.

There are a couple of caveats that come with using this event.

  1. If you're using a WinForm app, there is no gaurantee you will get this event before your application raises the Close event. 
  2. This event won't ever fire (without a lot of trickery) from a Console application.
  3. Setting Cancel to True will usually work but not always. 

That aside, if you just need to save some data and or do some quick book
keeping before exiting this will do the trick.


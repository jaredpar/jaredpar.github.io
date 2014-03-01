---
layout: post
---
I'm a huge fan of customizing my environment. As a developer my productivity
is tied to access to my favorite tools, documentation, scripts, plug-ins and
generally being happy with the look and feel of my computer. This runs
against me using a lot of computers in my job and at home. I spend a lot of
time writing scripts to keep my computers in good developer order by manually
synchronizing, installing tools, etc ...

This one reason I am a huge fan of [Live Mesh](http://www.mesh.com/). It
automatically synchronizes files between multiple PC's allowing me to forgot
about annoying web document storage,?? flaky Internet connections, etc.'? This
also means that any technology where configuration is based on files/folders
can use Live Mesh to synchronize configuration between machines.

Today I'm going to take a small departure from my normal technical blather and
explain how you can use this technology in order to make Internet Explorer
have the same favorites on all of the machines you run Live Mesh on.
Favorites are stored as shortcuts in a folder on your hard drive: namely
c:\users\yourusername\Favorites. The first step is to get this folder loaded
into Live Mesh. Navigate to c:\users\yourusername, right click on Favorites
and select "Add folder to your live Mesh"

![Mesh_Favorites_1](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter
/UsingLiveMeshtoSynchronizeFavorites_11BB0/Mesh_Favorites_1_thumb.png)

The folder will quickly upload into the Mesh. It will upload all of the
favorites from the machine where these actions took place.

Now go to another machine where you have Live Mesh installed. There will now
be a folder shortcut on your desktop named "Favorites". Click on that folder
and it will bring up the Live Mesh synchronization dialog. Choose the
location of favorites on the current machine. It will still likely be
c:\users\yourusername\Favorites.

![Mesh_Favorites3](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/
UsingLiveMeshtoSynchronizeFavorites_11BB0/Mesh_Favorites3_thumb.png)

Click Ok and it will bring up a warning saying it will merge the files in the
Favorites folder with the files on Live Mesh. Generally speaking this is OK
but I advise you to backup the folder first just in case. It will take Live
Mesh a few seconds to download the favorites but afterwards IE on both
machines will have the same favorites.

Adding, deleting and reordering favorites on one machine will now
automatically show up on all machines where you performed this install. Note,
I've had to restart IE occasionally to get it to recognize the newly added
favorites but this is a minor annoyance compared with getting favorites to be
the same everywhere.


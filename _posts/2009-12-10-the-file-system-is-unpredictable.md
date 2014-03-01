---
layout: post
---
One of the more frequent questions I answer on StackOverflow is a variation of
the following.

> I'm doing XXX with a file, how can I know if the file exists?

The variations include verify no one else has the file open, if the file is in
use, the file is not writable, etc '. The answer to all of these questions is
unfortunately the same. Simply put you can't. The reason why is the
fundamental nature of the file system prevents such predictive operations.

The file system is a resource with multiple levels of control that is shared
between all users and processes in the system. The levels of control include
but are not limited to file system and sharing permissions. At **any** point
in time any entity on the computer may change a file system object or it's
controls in any number of ways. For example

  * The file could be deleted 
  * A file could be created at place one previously did not exist 
  * Permissions could change on the file in such a way that the current process does not have access 
  * Another process could open the file in such a way that is not conducive to sharing 
  * The user remove the USB key containing the file 
  * The network connection to the mapped drive could get disconnected 

Or in short

> The file system is best viewed as a multi-threaded object over which you
have no reliable synchronization capabilities

Many developers, and APIs for that matter, though treat the file system as
though it's a static resource and assume what's true at one point in time will
be true later. Essentially using the result of one operation to predict the
success or failure of another. This ignores the possibility of the above
actions interweaving in between calls. It leads to code which reads well but
executes badly in scenarios where more than one entity is changing the file
system.

These problems are best demonstrated by a quick sample. Lets keep it simple
and take a stab at a question I've seen a few times. The challenge is to
write a function which returns all of the text from a file if it exists and an
empty string if it does not. To simplify this problem lets assume permissions
are not an issue, paths are properly formatted, paths point to local drives
and people aren't randomly ripping out USB keys. Using the System.IO.File
APIs we may construct the following solution.

    
    
    static string ReadTextOrEmpty(string path) {


        if (File.Exists(path)) {


            return File.ReadAllText(path); // Bug!!!


        } else {


            return String.Empty;


        }


    }

This code reads great and at a glance looks correct but is actually
fundamentally flawed. The reason why is the code changes depends on the call
to File.Exist to be true for a large portion of the function. It's being used
to predict the success of the call to ReadAllText. However there is nothing
stopping the file from being deleted in between these two calls. In that case
the call to File.ReadAllText would throw a FileNotFoundException which is
exactly what the API is trying to prevent!

This code is flawed because it's attempting to use one piece of data to make a
prediction about the future state of the file system. This is simply not
possible with the way the file system is designed. It's a shared resource
with no reliable synchronization mechanism. File.Exists is much better named
as File.ExistedInTheRecentPast (the name gets much worse if you consider the
impact of permissions).

Knowing this, how could we write ReadTextOrEmpty in a reliable fashion' Even
though you can not make predictions on the file system the failures of
operations is a finite set. So instead of attempting to predict successful
conditions for the method, why not just execute the operation and deal with
the consequences of failure?

    
    
    static string ReadTextOrEmpty(string path) {


        try {


            return File.ReadAllText(path);


        } catch (DirectoryNotFoundException) {


            return String.Empty;


        } catch (FileNotFoundException) {


            return String.Empty;


        }


    }

This implementation provides the original requested behavior. In the case the
file exists, for the duration of the operation, it returns the text of the
file and if not returns an empty string.

In general I find the above pattern is the best way to approach the file
system. Do the operations you want and deal with the consequences of failure
in the form of exceptions. To do anything else involves an unreliable
prediction in which you still must handle the resulting exceptions.

If this is the case then why have File.Exist at all if the results can't be
trusted' It depends on the level of reliability you want to achieve. In
production programs I flag any File.Exist I find as a bug because reliability
is a critical component. However you'll see my personal powershell
configuration scripts littered with calls to File.Exsit. Simply put because
I'm a bit lazy in those scripts because critical reliability is not important
when I'm updating my personal .vimrc file.


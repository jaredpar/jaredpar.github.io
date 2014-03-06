---
layout: post
---
It's nice to have powershell when you need to do a lot of redundant file work.  I'm use Subversion as the source code control backing for a lot of my hobby projects.  I have pretty much all the code I've ever written as a hobby or for school stored in SVN.

The biggest downside to using Subversion is integration tracking.  Subversion doesn't do a lot of in house integration tracking (it just looks like more edits).  If you follow the subversion guidelines this isn't much of a problem and everything will go as expected.

Unfortunately I didn't follow those guidelines.  I glossed over one of the most important parts and as a result I lost track of the integrations I did and didn't do.  So today when I tried to do a large merge, SVN got confused and saw tons of my files as having conflicts.  When SVN hits a conflict during any operation it will mark the file as "conflict" put all of the changes into the main file (Call it foo.cs) and then create the left and right files (foo.cs.merge-left.rxxx, foo.cs.merge-right.rxxx).  Left is typically the file on your disk with the right file being the one you're trying to merge in.

Really I just wanted the changes from the most recent revision (the right file in this case).  In this case since I just wanted the newest version the process was to copy the right file and mark the file as resolved.  Lots of tedious hand work.

Powershell let me fix the problem with 1 minute of script work.

I still think one the most valuable uses for PowerShell is just playing with .Net.   I knew that I could use a regex to match the files with right files and capture the actual name of the file as well.

It took only two quick command line experiments with PowerShell to determine the way of grouping the name of the file as part of the regex.  Result being that if you separate a regex into groups with parens then they will be added (by number) into the $matches variable.  So the following will match all *.merge-right.rXXX files and capture the original file name in $matches[1].

    "(.*)\\.merge-right.*"

So I ran the following script in my directory that was having issues and all was well again.

    PSH:> foreach ( $file in dir) { if ( $file.Name -matches "(.*)\\.merge-right.*" ) { copy $file.Name $matches[1]; svn resolved $matches[1] } }








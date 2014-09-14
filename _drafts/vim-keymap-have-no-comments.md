---
layout: post
title: Vim key maps don't have comments
---
One of the fun benefits of running VsVim is that I'm constantly exposed to the amazing ways that vim can be configured.  Many bugs in VsVim have to deal with commands that show up in vimrc files.  Users are quick to share these files to help in tracking down the bug.  The amount of customization that goes into these files is quite daunting and a reminder of just how flexible an editor vim really is.   

But when I'm looking through these files I occasionally spot subtle bugs in the vimrc itself.  Usually due to misconception in how various vim commands are implemented.  One issue I see quite frequently is comments being added to key mappings.  For example: 

```
:nmap > >> " shorter shift command
```

Usually I'm a big fan of comments, even in script files, if they add appropriate context.  The problem though is that these aren't actually comments because key maps don't have comments.  From the help section [map-comments](http://vimdoc.sourceforge.net/htmldoc/map.html#map-comments): 

> It is not possible to put a comment after these commands, because the '"' character is considered to be part of the {lhs} or {rhs}.

This means "shorter shift command" isn't a comment but in practice it appears to act like one.  It doesn't seem to have any effect on the key mapping.  The `>` key will now behave (virtually) identical to `>>`.  

So if this isn't a comment why is it acting like one?  The reason is buried inside the same [help page](http://vimdoc.sourceforge.net/htmldoc/map.html#map_return):

> Note that when an error is encountered (that causes an error message or beep) the rest of the mapping is not executed.  

In normal / visual mode the `"` key beigns a register sequence and must be followed by a valid register name.  The `<Space>` key is not a valid register name which results in an error that causes vim to discard the rest of the key mapping.  This particular error produces no messagge though, only a beep which many vmircs also disable.  

This all combines to giving this the appearance of being a comment.  In actuality though it's just an invalid command.  

The correct way to add comments to a key mapping is to put them on a separate line 

```
" shorter shift commnad
:nmap > >>
```



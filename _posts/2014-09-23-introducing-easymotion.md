---
layout: post
title: Easy Motion for Visual Studio
tags: vsix
---
Easy motion is a plugin for [Sublime](https://github.com/tednaleid/sublime-EasyMotion) that allows for quick and simple keyboard navigation within a file [^1].  Just 3 key strokes can take you to any visible letter.  No neeed for complex regexes or patterns, all you need to know is the letter that you want to navigate to. 

A user alerted me to this sublime plugin a month or so ago and I immediately started using it.  I absolutely loath touching the mouse or arrow keys during development because I feel it slows me down.  Typically I use vim style editors to avoid the mouse.  But the steep learning curve of vim shouldn't be a prerequisite for efficient keyboard navigation.  Easy motion represents a great middle ground here for developers who want to get more productivite with a minimal learning curve.  

So a few weekends ago I sat down and coded up an Easy Motion clone for Visual Studio.  Been toying with it for a few weeks now and it's ready to be shared out more generally.  

- [Easy Motion Extension](http://visualstudiogallery.msdn.microsoft.com/86548753-2b00-42e0-a40c-185f93e37a4f)
- [Source Code](https://github.com/jaredpar/EasyMotion)

Here is a simple example of how to use EasyMotion to jump around within a file.  Let's start with a `"Hello World"` program that has the cursor positioned at the end of a using directive.  

![example 1](/images/posts/easymotion1.png)

Now I want to move the caret to the start of `Console.WriteLine`.  Instead of moving my hands to the arrow keys, or even worse grabbing the mouse, I initiate an easy motion search by pressing `Shift+Control+;`.  

![example 2](/images/posts/easymotion2.png)

In response the editor added a status line asking me for the character I want to search for.  I type `C` as it is the first letter in `Console.WriteLine`.  

![example 3](/images/posts/easymotion3.png)

There are many occurences of `C` in the file and Easy Motion distinguishes between them by overlaying every occurence with a new letter (a-z). To jump to a specific instance of 'C' I simply type in the letter which overlays the 'C' I want to jump to.  In this case it is 'I' 

![example 4](/images/posts/easymotion4.png)

Now the caret is positioned exactly where I wanted at the start of `Console.WriteLine`.  No arrow keys, no mouse, just 3 quick keyboard touches and I'm there 

[^1]: The Sublime plugin is itself a clone of a [vim extension](https://github.com/Lokaltog/vim-easymotion)

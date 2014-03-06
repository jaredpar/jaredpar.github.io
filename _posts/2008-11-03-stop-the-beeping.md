---
layout: post
---
Recently I was working on a PowerShell script which involved translating byte arrays into strings using the appropriate encoding. Unfortunately I kept getting the wrong choice for encoding and printed out essentially random data to the console screen.  

Unfortunately random data + windows console screens = beeps, beeps and lots more beeps.

What's even worse is these beeps queue up. Almost a full minute after a given encoding mistake I was still paying the price. Highly annoying.

There is no way to disable the beeps on an individual console level. But it can be disabled on a system wide level. Beep is a windows service so it just needs to be stopped 

> net stop Beep

This does need to be executed with Admin privileges. After that I can code beep free.


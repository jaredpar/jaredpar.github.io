---
layout: post
title: Understanding VBCSCompiler
---

Visual Studio 

Starting with Visual Studio 2015 there is a new process a lot of users are seeing: VBCSCompiler.  This is a process we added to make 
batch compilations faster and blah ablah blah

Starting with Visual Studio 2015 a lot of users began noticing a new process when running Visual Studio: VBCSCompiler. 

This proces is meant to help batch compilations in a number of ways: NGEN and reference caching. 

Numbers

Hash 40b34f304dfa19481d4817e33960e5c24f746117 

Default Toolset build Roslyn.sln

Days              : 0
Hours             : 0
Minutes           : 2
Seconds           : 5
Milliseconds      : 860
Ticks             : 1258602742
TotalDays         : 0.00145671613657407
TotalHours        : 0.0349611872777778
TotalMinutes      : 2.09767123666667
TotalSeconds      : 125.8602742
TotalMilliseconds : 125860.2742
I/O Reads 3.1 Gig

NoCache Toolset build Roslyn.sln

Days              : 0
Hours             : 0
Minutes           : 2
Seconds           : 11
Milliseconds      : 600
Ticks             : 1316003186
TotalDays         : 0.00152315183564815
TotalHours        : 0.0365556440555556
TotalMinutes      : 2.19333864333333
TotalSeconds      : 131.6003186
TotalMilliseconds : 131600.3186
I/O Reads 4.0 Gig

1000 Cache 

Days              : 0
Hours             : 0
Minutes           : 1
Seconds           : 56
Milliseconds      : 874
Ticks             : 1168744873
TotalDays         : 0.00135271397337963
TotalHours        : 0.0324651353611111
TotalMinutes      : 1.94790812166667
TotalSeconds      : 116.8744873
TotalMilliseconds : 116874.4873

1000 Cache with Warm Server

Days              : 0
Hours             : 0
Minutes           : 1
Seconds           : 50
Milliseconds      : 824
Ticks             : 1108247080
TotalDays         : 0.00128269337962963
TotalHours        : 0.0307846411111111
TotalMinutes      : 1.84707846666667
TotalSeconds      : 110.824708
TotalMilliseconds : 110824.708




Count 22743 Hit Count 7158 Percent 0.31473420393088


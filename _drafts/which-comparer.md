---
layout: post
title: Which comparer to use for file system paths? 
tags: [filesystem, misc]
---

Create the file system
[mono-20150316155603]jaredpar@ubuntu:~/temp$ dd if=/dev/zero of=~/temp/raw-file-1 bs=1024 count=100
100+0 records in
100+0 records out
102400 bytes (102 kB) copied, 0.0019748 s, 51.9 MB/s

[mono-20150316155603]jaredpar@ubuntu:~/temp$ mkfs.fat raw-file-1 
mkfs.fat 3.0.26 (2014-03-07)

Mount and have fun 
[mono-20150316155603]jaredpar@ubuntu:~/temp$ sudo umount /dev/loop1
[mono-20150316155603]jaredpar@ubuntu:~/temp$ sudo mount raw-file-1 ~/temp/fstest/ -o loop -w -t vfat -ouser,umask=0000

Now I actually have a path where parts are case sensitive and parts are case insensitive: 

``` 
$> echo test > fstest/test.txt
$> cat fstest/test.txt
test
$> cat fstest/TEST.TXT
test
$> cat FSTEST/TEST.TXT
cat: FSTEST/TEST.TXT: No such file or directory
```

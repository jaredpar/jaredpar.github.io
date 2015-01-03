---
layout: post
title: Don't use types as property bag keys
tags: [vsix]
---

Property bags are a common feature of the WPF editor APIs.  This is a great way for extensions to add a piece of data which represents an implementation detail to an existing editor data structure.  

The key here is this data is generally an implementation detail.  Data to which other extensions should not have directy access.  All such access should be controlled through APIs.  Giving developers direct access to the data inhibits your ability to change the underlying data storage at a later time.  Maybe you find there is a better type on which to store the data. 

Whether or not this is supported is debatable.  One thing that is a virtual certainty is that Visual Studio can never change this behavior.  There is a non-trivial amount of code on the web which already depends on this.  Changing this API would break it for no particular gain.

The best way to prevent users from taking a dependency on your key is to make it unpredictable.  Give it a value that changes on every startup

A better approach to solving this problem is to use a key which can't be predicted by the calling application.  The simplest example is a new `object` instance:

``` csharp
sealed class TextDocumentFactoryService 
{
    private static object Key = new object();
}
```



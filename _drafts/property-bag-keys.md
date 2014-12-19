---
layout: post
title: Don't use types as property bag keys
tags: [vsix]
---

Whether or not this is supported is debatable.  One thing that is a virtual certainty is that Visual Studio can never change this behavior.  There is a non-trivial amount of code on the web which already depends on this.  Changing this API would break it for no particular gain.

The best way to prevent users from taking a dependency on your key is to make it unpredictable.  Give it a value that changes on every startup



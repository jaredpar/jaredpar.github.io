---
layout: post
---
When running FxCop on any managed code that uses CoSetProxyBlanket you will
see an error message saying the method cannot be called reliably from managed
code.  I've hit that message before was frustrated by my attempts to find an
explanation on the web.  Part of the reason is I'm not the most efficient
searcher on the web.

However and internal discussion revealed to me a great blog entry explaining
exactly why this is unreliable and more importantly how to work around the
issue.

<http://blogs.msdn.com/mbend/archive/2007/04/18/cosetproxyblanket-not-
supported-from-managed-code.aspx>



Technorati tags: [DotNet](http://technorati.com/tags/DotNet)


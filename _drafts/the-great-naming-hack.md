---
layout: post
title: The Great Naming Hack
---
Everyone who has worked on a legacy code base remembers that special piece of code that showed them in great detail exactly what they were getting into.  That code which screamed out 

What is truly special though is that first piece of *code* that which screamed out

> Run!!!

Everyone who has worked on a legacy code base remembers that special piece of code that showed them in great detail exactly what they were getting into.  That code which screamed out 

> This code base is older than you.  For your entire life developers have been making and obfuscating mistakes in this code.  


{% highlight csharp %}
struct SymbolNode : ExprNode
{
  union
  {
    ExprNode*  pnodeQual;
    ExprNode*  BaseReference;
  };

  union
  {
    NameNode* pnamed;
    NameNode* Symbol;
  };
};
{% endhighlight %}

Luckily one of the existing developers was on the team when this was introduced and provided the history of this change.  At some point in the past the team had entered into one of the great religous programming debates

> Hungarian Notation or No Hungarian Notation

The outcome to let developers use whichever they like in the files they owned.   


The good news is this code no longer exists. After learning the history of this *construct* the team quickly decided to abolish it.  We took a vote, decided against hungarian notation, deleted all of the unions keeping the non-hungarian member only and spent the next day doing all of the necessary renames to account for the change.  

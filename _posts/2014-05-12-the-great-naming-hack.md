---
layout: post
title: The Great Naming Hack
tags: fun
---
Inheritting a legacy code base is a rite of passage for developers.  This is the event which takes you from the mentality of clean, documented, tested code you wrote during university into the ugly real world of compromises.  It is very much a ["how the sausage is made"](http://quoteinvestigator.com/2010/07/08/laws-sausages/#more-905) moment

My first experience with this was transitioning to the languages team in Visual Studio back in 2006.  The C++ code base I inheritted was mostly written from 1998 onwards but had significant portions which were much, much older.  There were no enforced standards at the time hence developers checked in whatever style or practice they wished

As you can imagine that kind of environment creates quite a few humorous gems over time.  Even after years of working there we'd still find new ones every few weeks.  The one that will always stick with me though is *the great naming hack*.  It is best exemplified by this sample

``` c++
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
    NameNode* Name;
  };
};
```

Typically a unions are used when two mutually exclusive pieces data are present in the same data structure.  It uses a single storage location for all the values hence removing wasted space.  When I first encountered this my thought was 

> How could a union possibly be relevant here? All of the members are of the same type, they just have different names.

Luckily one of our developers was on the team when this was introduced and was able to provide the history of this change.  At some point in the past the team had entered into one of the great religous programming debates 

> Hungarian Notation or No Hungarian Notation?

Unfortunately they were not able to reach a concencus.  Instead the outcome was to let developers use whichever they liked in the files they owned.  As a warning to others files were marked with comments of "hungarian notation only" or "no hungarian notation" at the top.  But they still struggled on how to handle data structures shared between files.  Until that is one developer had an epiphany

> We can use a union to create multiple names for the same field.  This way every field can have a hungarian and non-hungarian name!!!

The result is pretty much the chaos you are probably envisioning right naw.  Many files used 'pnodeQual', others used 'BaseReference' and anyone who crossed between such files had to alternate between them based on the style of the current file.  It was ... difficult to deal with. 

Unlike many legacy code stories though this one has a happy ending.  After learning the history of this *construct* the team quickly decided to abolish it.  We took a vote, decided against hungarian notation and spent the time necessary to delete the unions from the shared data structures.  


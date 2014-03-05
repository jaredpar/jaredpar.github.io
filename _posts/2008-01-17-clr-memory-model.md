---
layout: post
---
Internally and externally I see a lot of questions about the .Net Memory Model.  I think a lot of the confusion comes from the specs.  Mainly that there are really two of them.

The first is the [ECMA CLI Memory Model](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-335.pdf) (Partition 1, Section 12).  This standard introduces a relaxed memory model which, IMHO, makes multi-threading program a bit difficult.  For instance it allows for write reordering which can be quite confusing to programmers (and result in very hard to track bugs).

The CLR 2.0 Memory Model is a stricter version of the EMCA model.  There are two excellent sources of information on the more strict version.

  * <http://msdn.microsoft.com/msdnmag/issues/05/10/MemoryModels/>  \- Vance Morrison's detailed article on multi-threaded apps and locking techniques.  He goes into a bit of detail on how the ECMA and CLR 2.0 models differ and the justification for making them do so. 
  * <http://www.bluebytesoftware.com/blog/2007/11/10/CLR20MemoryModel.aspx> \- Joe Duffy sums up Vance's article and defines a set of 6 simple rules to the memory model. 

For anyone doing multi-threaded programming in .Net, both of these articles are a must read.


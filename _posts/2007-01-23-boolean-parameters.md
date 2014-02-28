---
layout: post
---
An item I try to avoid in any API I create are methods which ...

  1. Take more than one parameter
  2. One of the parameters is a boolean

Typically this pattern indicates a True/False option on an operation type.
This boolean value turns on or off some type of scenario for that operation.

The reason I dislike this is that it's not maintainable.  I constantly forget
what the boolean value means and it makes my code less readable to people who
are reviewing.  The reviewer sees SomeOperation(1, true) and they constantly
ask "What does true mean?".  And even though most programmers won't admit
this, years after you write the code and you're tracking down a bug, you also
forget what true meant in this case.

Instead I prefer to break down the operation into three different methods.
Say the operation in question loaded a particular piece of data from a file.
The data block can have references to other data blocks.  In some cases I only
want the first layer of data and in others I would like to load all
referencable data blocks.  Here is the break down of operations I will create.

  1. public LoadDataBlock(identifier)
  2. public LoadDataBlockRecursive(identifier)
  3. private LoadDataBlockImpl(identifier, recursive)

The private implementation takes the boolean indicating the option.  This
gives the implementor of the method the flexibility of having the boolean
option parameter.  The big win here is for the caller.  They don't need to
know about this hidden parameter and instead will have two clear API method
calls.




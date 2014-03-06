---
layout: post
---
I think the best answer is: rarely.'? It's really hard to go straight to a justification here though. I find that answering a different question will eventually shed led on when to create a new exception.

> "What are the benefits of creating a new/custom exception?"

The answers I come up with or have heard before are ...

  1. Provides a type safe mechanism for a developer to detect an error condition.

Without a custom exception a developer would be forced to compare an existing value on an existing exception class in order to determine if a particular error occurred. To ensure this was unique across applications and environments a unique identifier would need to be inserted as well (likely a GUID). The resulting code would be quite ugly and maintainability would be a question mark.

  2. Add situation specific data to an exception 

Ideally this data would help another developer track down the source of the error.

But an entirely new exception is not needed to achieve this goal. The base Exception class contains a property named [Data](http://msdn.microsoft.com/en-us/library/system.exception.data.aspx) which is an open dictionary. Any code which raises an exception is free to add custom data into the exception. This data can then be accessed by the handling code. Unique values still need to be dealt with. But in my experience, accessing a GUID based custom property is a bit more accepted than catching an exception based on some GUID property.  

This is especially true now with extension methods. The lack of type safety in the dictionary and potentially constant string sharing for property names could be hidden inside an extension method

  3. No existing exception adequately described my problem 

I'd argue against this because of [InvalidOperationException](http://msdn.microsoft.com/en-us/library/system.invalidoperationexception.aspx). Invalid operation should cover most exceptional cases

So of these reasons only #1 is a stand alone benefit of a new exception. Now lets re-state this advantage in the context of the original question.

> Creating a new exception allows a developer to catch them

Simple right' But what benefit does this give to a developer' From my experience there are only two reasons to catch an exception.

  * It's a particular for which the underlying exceptional problem can be corrected. Perhaps the user is prompted to fix the condition by performing some outside action (like re-inserting a disk).
  * Logging errors for post-mortem debugging. Note: You could also use the Data dictionary and extension methods above to introduce a new method ShouldLog(). This would allow you to avoid creating a new exception type.

Now I think we can answer the original question of this blog post.

> You should only create a new exception if you expect developers to take corrective action for the problem or to log for post mortem debugging.

Otherwise, what benefit does creating this exception give you?


---
layout: post
title: Testing for VSIX Memory Leaks
categories: vsix 
---

A common bug in VSIX projects is to hold onto an `ITextView` instance long after it has been [closed](http://msdn.microsoft.com/en-us/library/microsoft.visualstudio.text.editor.itextview.close.aspx).  This is problematic because it ends up preventing a large number of resources from being collected including the `ITextBuffer`, language service elements, WPF items, other extension objects, etc ...  In short it is a substantial memory leak.  

The vast majority of these leaks occur with the following pattern:

1. A VSIX MEF component hooks into an event that has a lifetime not tied to a particular `ITextView` instance.  For example: an extension listening to a settings changed event 
2. The event handler transitively contains a reference to an `ITextView`.  

Instant memory leak.

This problem is not specific to VSIX but more of a general issue with .Net event handling.  MEF tends to maginify this problem because it makes it so easy to connect componens with very different lifetimes.  Just slap a `[Import] ISettingsService` on a field and that global service is now available for use in any context.  

Spotting these leaks is difficult at best even in a moderately sized extension.  MEF hides so much of the interaction betwene components that it's often hard to understand how the lifetimes relate to each other.  The only real way to avoid this problem is to test for it. 

Testing for a memory leak is actually rather straight forward.  

1. Create the object you are concerned about leaking and save a copy in a weak reference
2. Run the scenario 
3. Clear all strong references to the object in the test code and run the GC a few times
4. If the weak reference still has a value then the scenario leaked memory 





## Creating a MEF container

The best way to test for memory leaks is to create the exact scenario that occurs at runtime.  This means creating a MEF container which includes the WPF Editor, your extensions and mocks for any VS services that your extension consumes.  

The easiest way to do this is to leverage the [EditorUtils](https://github.com/jaredpar/EditorUtils) project.  It is available on NuGet and has APIs for doing exactly this 

This may seem like an onerous process to go through but the results are work it.  Early versions of VsVim were plauged with memory leaks.  After tracking down a particularly nasty one I took the time to add these suites to the code base.  They have saved me from introducing new leaks countless times since then.  

#CODE SNIPPET

## Create instance of the editor


## Run the extension scenario 



## Testing for the leak

The actual test for the 


``` csharp
public sealed class MyTests : IDisposable 
{
  [Fact]
  public void Scenario1()
  {
    WeakReference<ITextView> 
  }
}
```

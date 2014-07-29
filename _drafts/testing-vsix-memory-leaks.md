---
layout: post
title: Testing for VSIX Memory Leaks
---
Memory leaks are incredibly easy to create in Visual Studio.  

The vast majority of leaks occur in the following way 

1. A VSIX MEF component hooks into an event has a lifetime not tied to a particular `ITextView` instance.  
2. The event handler transitively contains a reference to an `ITextView`.  

The event lives longer than the `ITextView` and has a reference to it.  Instant memory leak.  

MEF in some ways makes this problem worse because it is so easy to connect components with very different lifetimes.  Just stick a `[Import] ISettingsService` on a component and that global service is is now available for use.  

MEF makes it so easy to create these leaks because the hookup mechanism essentially hides relative lifetimes.  Just stick a `[Import] IRandomService` on a field and it's available.  I

Could be as easy as a component adding an event handler for a settings change event and holding a reference to the `ITextView`.  

## Creating a MEF container

The best way to test for memory leaks is to create the exact scenario that occurs at runtime.  This means creating a MEF container which includes the WPF Editor, your extensions and mocks for any VS services that your extension consumes.  

The easiest way to do this is to leverage the [EditorUtils](https://github.com/jaredpar/EditorUtils) project.  It is available on NuGet and has APIs for doing exactly this 

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

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

This problem is not specific to VSIX but more of a general issue with .Net event handling.  MEF tends to maginify this problem because it makes it so easy to connect components with very different lifetimes.  Just slap a `[Import] ISettingsService` on a field and that global service is now available for use in any context.  

Spotting these leaks is difficult at best even in a moderately sized extension.  MEF hides so much of the interaction between components that it's often hard to understand how the lifetimes relate to each other.  The only real way to avoid this problem is to test for it. 

Testing for a memory leak is actually rather straight forward:

1. Create the object you are concerned about leaking and save a copy in a weak reference
2. Run the scenario 
3. Clear all strong references to the object in the test code and run the GC a few times
4. If the weak reference still has a value then the scenario leaked memory 

To apply this pattern to a VSIX project it means creating instances of `ITextView`.  The only realistic way to do this is to create a MEF container which has both the Visual Studio WPF editor and the necessary parts of your extension.  Doing this by hand is [rather tricky](https://github.com/jaredpar/EditorUtils/blob/master/Src/EditorUtils/EditorHostFactory.cs).  A much easier way is to leverage the [EditorUtils](https://github.com/jaredpar/EditorUtils) project.  It is available on NuGet and has APIs for doing exactly this.  

{% highlight csharp %}
using EditorUtils;
...
var editorFactory = new EditorHostFactory();
editorFactory.Add(new AssemblyCatalog(typeof(MyExtension).Assembly));
var editorHost = editorFactory.CreateEditorHost();
var textView = editorHost.TextEditorFactory.CreateTextView();
{% endhighlight %}

The `EditorHostFactory` type is responsible for creating the MEF container.  The `editorFactory.Add` line is simply inserting the assembly of VSIX extension being tested into the container.  The resulting `EditorHost` instance wraps a MEF container with both the VS editor and the targetted extension.  Now extension elements will be created exactly as they are when running in Visual Studio.  This makes writing tests extremely easy.  

{% highlight csharp %}
[Fact]
public void Scenario()
{
  ITextView textView = CreateCSharpTextView();
  textView.TextBuffer.Insert(0, "hello world");
  textView.Close();
}
{% endhighlight %}

The `Insert` line naturally needs to be replaced with some code which excercises your extension.  Also this is relying on the test being within the larger test template outlined below.  The first reaction you may have when looking at this template is:

> Holy crap! That's quite a bit of boiler plate code! 

Yes indeed it is.  Unfortunately it's all necessary to ensure the leak detection is done properly.  Good news though is the code is copy, paste and forget.  The actual test logic is mostly unaware of this pattern (and it can be abstracted out to a base type if that suits your needs better) 

Overall this may seem like an onerous process to go through.  But let me assure you that the results are worth it.  Early versions of [VsVim](http://visualstudiogallery.msdn.microsoft.com/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329) were plagued with memory leaks.  After tracking down a particularly nasty one for the umpteenth time I decided to take the time to work through these tests.  They have saved me from introducing new leaks countless times since then.  

The test template 


{% highlight csharp %}
public class MemoryLeakTest : IDisposable
{
    readonly EditorHost m_editorHost;
    readonly List<WeakReference> m_textViewList = new List<WeakReference>();

    public MemoryLeakTest()
    {
        var editorFactory = new EditorHostFactory();
        editorFactory.Add(new AssemblyCatalog(typeof(MyExtension).Assembly));
        m_editorHost = editorFactory.CreateEditorHost();
    }

    public void Dispose()
    {
        RunGarbageCollector();

        foreach (var weakReference in m_textViewList)
        {
            Assert.False(weakReference.IsAlive);
        }

        // Don't let the GC collect the MEF container and hence hide the leaks 
        GC.KeepAlive(m_editorHost);
    }

    static void RunGarbageCollector()
    {
        for (var i = 0; i < 15; i++)
        {
            // Got to clear out any lingering WPF actions which may hold onto the ITextView
            DoEvents();
            GC.Collect(2, GCCollectionMode.Forced);
            GC.WaitForPendingFinalizers();
            GC.Collect(2, GCCollectionMode.Forced);
            GC.Collect();
        }
    }

    static void DoEvents()
    {
        var dispatcher = Dispatcher.CurrentDispatcher;
        var frame = new DispatcherFrame();
        Action<DispatcherFrame> action = _ => { frame.Continue = false; };
        dispatcher.BeginInvoke(
            DispatcherPriority.SystemIdle,
            action,
            frame);
        Dispatcher.PushFrame(frame);
    }

    ITextView CreateCSharpTextView()
    {
        var contentType = m_editorHost.GetOrCreateContentType("csharp", "code");
        var textView = m_editorHost.CreateTextView(contentType);
        m_textViewList.Add(new WeakReference(textView));
        return textView;
    }
}

{% endhighlight %}

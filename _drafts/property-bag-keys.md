---
layout: post
title: Don't use types as property bag keys
tags: [misc]
---

Property bags are a common feature of the UI and extensibility frameworks.  They allow consumers to easily associate arbitrary data with an existing framework element.  This data has relatively inexpensive access and shares the lifetime of the framework element.  Typically consumers use property bags for one of the following purposes:

1. Share data with other components using the framework.  The framework element acts as a share point. 
2. Allows a component to associate implementation data with an existing element. 

In the case of the first item having a known, and recreatable, key is a requirement of the sharing.  Items like `GUIDs`, known `string` values, etc ... are commonly used.  

In the second case though having a known key is akin to having the implementation data be `public`.  It makes it trivial for any other consumer to come in and read the implementation data directly instead of going through APIs the consumer defined access the data.  

The most common offender I see in this area is using `Type` values as property bag keys:

``` csharp
public interface IDocument { } 

public sealed class DocumentService
{
    public IDocument CreateTextDocument(IBuffer buffer)
    {
        var doc = new Document();
        buffer.Properties[typeof(IDocument)] = doc;
        return doc;
    }

    public IDocument GetTextDocument(IBuffer buffer)
    {
        Document doc;
        if (buffer.Properties.TryGetValue(typeof(IDocument), out doc)) 
        {
            return doc;
        }

        throw new Exception("No document");
    }
}
```

Here the service is using the property bag to hold implementation detail.  It wants to control the association between `IBuffer` and `IDocument` values and provide APIs to manage it.  Yet it's using a key that any consumer can create themselves.  Why go through the trouble of using the service at all when they can just do the following? 

``` csharp
void M(IBuffer buffer) 
{
    IDocument doc = buffer.Properties[typeof(IDocument)];
    ...
    // I'm done with this
    buffer.Properties.Remove(typeof(IDocument));
}
```

At this point the service has simply lost control of its data.  It can't do any kind of counting, caching, etc ... because it must consider its data public.  This is not a theoretical problem, this actually happens quite frequently in VSIX applications for instance.  

The best way to prevent consumers from taking such a dependency is to use a key that is unpredictable.  For example a value that changes on every startup which can't be predicted by the consumers.  Such a value is actually quite easy to create: 

``` csharp
public sealed class DocumentService
{
    private static object DocumentKey = new object();
}
```

True, consumers could find this key by searching through all key / value pairs.  But it does up the bar significantly from a simple `typeof()` + index expression.  In practice it's often more than enough to get developers to use the APIs that were intended in the first place. 


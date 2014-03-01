---
layout: post
---
As I've developed [VsVim](https://github.com/jaredpar/VsVim/) over the years I've authored quite a few reusable Visual Studio components.  For the last 6 months I've had many of these factored out to a separate utility library and this last week I decided to publish them as a separate [NuGet](http://nuget.org/) package.  Even if no one else every uses the library I want to reuse the utilities in other projects I'm working on and NuGet is the perfect distribution mechanism.  For those interested I'll be blogging about these components and why I authored them in the coming weeks (hint: perf, perf and more perf).  I wanted to blog about my the rules I learned from this exercise because even as a seasoned extension author I hit a couple of very surprising problems along the way.  Hopefully the lessons I learned will help out the next person to attempt this 

# Utility libraries must be strongly named

This is an unfortunate truth of authoring a utility library in Visual Studio.  If you intend to ever release more than one version of a utility library then you must accept that there will be two extensions referencing different versions of your library in the same instance of Visual Studio.  Unless the assemblies are signed the CLR will only load one version into the AppDomain.  This means one extension will see the version it expects and the others won't.  This would be disastrous if the newer version of the library had new MEF interfaces, features, etc ... Simply being very diligent with version numbers just isn't enough here.  When comparing a DLL reference to a DLL loaded in memory the CLR will ignore version numbers on unsigned assemblies [1].  If an app has a reference to MyUtility.dll at Version 99 and MyUtility.dll at Version 1 is loaded the CLR will consider it a match.  There's nothing I'm aware of, other than strong names, that will change this behavior.  

This also means you can't even rely on the latest version of your utility library being loaded.  Extension load order is not defined in Visual Studio [2].   Hence it's quite possible that extension referencing the oldest version of your utility library loads first and establishes that version as the one every other extension will use.

When an assembly is strongly named the CLR will respect version numbers and load multiple versions of the assembly into the AppDomain at the same time.  Every extension will then see the version they are expecting independent of what other extensions are installed on the machine.  

# MEF isn't version safe by default

MEF gives the appearance of being a model that deals in terms of types.  Contracts are typically defined in terms of interfaces, [Export] of the implementation use a typeof experession and the associated [Import] is tagged on a type location.  Everything about it screams Type, yet MEF doesn't actually deal in terms of types, it primarily deals in terms of strings.  Specifically in the form of a contract name and type name.

Every export and import have a contract name and type name associated with them.  Only when both the contract name and type name match does MEF consider an Import and Export to match.  Consider:

{% highlight csharp %}
    [Export(typeof(IObjectCache))]
    internal sealed class ObjectCache : IObjectCache {
    
    }
{% endhighlight %}

The above code did not create an export of the .Net type IObjectCache or even it's assembly qualified name.  Instead it created an export with

  * Contract Name: SomeNamespace.IObjectCache
  * Type Name: SomeNamespace.IObjectCache

Note: If you don't specify a contract name explicitly MEF will just reuse the type name it generates

Notice that no assembly information is captured in this export.  It's just a type name plus the enclosing namespace.  This contract will match up with any other Export of a type with the same fully qualified name as IObjectCache in any assembly loaded into the AppDomain.  And this is **exactly** what will happen if you have multiple versions of your library loaded into the Visual Studio process [3]

In order to have version same MEF components the export and import contracts need to be different for different versions of your library.  The easiest way to achieve this is to embed the assembly version into the contract name portion of an Export and Import.  In my projects I achieve this by means of a constant which I reuse in my AssemblyVersion attribute and Exports

{% highlight csharp %}
    public static class Constants {
        public const string AssemblyVersion = "1.0.0.0";
        public const string ContractName = "MyUtility " + AssemblyVersion;
    }

    [Export(Constants.ContractName, typeof(IObjectCache))]
    internal sealed class ObjectCache : IObjectCache {

    }

    [assembly: AssemblyVersion(Constants.ContractName)]
{% endhighlight %}

Unfortunately this messiness isn't something that can be self contained within your library.  It's a price you must push down to your consumers as well.  Their [Import] attributes must have the same contract name else MEF won't consider them a match and will reject the composition.  Hence consumers of your library must use a similar pattern.
    
{% highlight csharp %}
public class MyService {
    [ImportingConstructor]
    public MyService([Import(Constants.ContractName)] IObjectCache objectCache)
    {

    }
}
{% endhighlight %}


This applies to all ImportingConstructor, Import and ImportMany usage of your types.

Both of these lessons set me back quite a bit.  But eventually I was able to produce the [EditorUtils](https://nuget.org/packages/EditorUtils) package I'd been working on and change [VsVim](https://github.com/jaredpar/VsVim/tree/nuget) to use it.  Hopefully there aren't many more surprises waiting for me around the corner 

[1] Except for Silverlight

[2] Unless there is an explicit entry in the manifest file declaring a
dependency. Won't ever happen for unrelated extensions.

[3] If this surprises you then you're not alone. I frankly disbelieved the
first person who told me this and had to create a sample app to prove it to
myself


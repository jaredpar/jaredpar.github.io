---
layout: post
title: DebuggerDisplay Attribute Best Practices
---
The [DebuggerDisplayAttribute](http://msdn.microsoft.com/en-us/library/system.diagnostics.debuggerdisplayattribute.aspx) is a powerful way to customize the way values are displayed at debug time. Instead of getting a simple type name display, interesting fields, properties or even custom strings can be surfaced to the user in useful combinations

{% highlight csharp %}
[DebuggerDisplay("Student: {FirstName} {LastName}")]
public sealed class Student {
    public string FirstName { get; set; }
    public string LastName { get; set; }
}
{% endhighlight %}

The DebuggerDisplay attribute can customize the name, value and type columns in the debugger window. Each one can be customized using a string which can contain constant text or expressions to be be evaluated by the expression evaluator. The latter is designated by putting the expression inside {}'s (this greatly resembles String.Format)

This feature while very powerful and useful can also easily contribute negatively to the debugging experience when used improperly (mostly in the area of performance). After several years of working in this area and helping customers out with bugs I've come up with a few recommendations to help prevent this from happening [1]

## Don't use multiple functions or properties in the display string

Every time I see a DebuggerDisplay attribute like the following I cringe a little inside

{% highlight csharp %}
[DebuggerDisplay("Student: {FirstName} {LastName} {Age} {Birthday} {Address}")]
{% endhighlight %}

Hands down the most expensive operation the expression evaluator does is evaluate a function. It dwarfs every other performance metric and can have a visible effect on stepping performance [2].'? This is true for both functions and properties (as far as the debugger is concerned there is almost no difference between the two).

Every one of the expression holes above results in a property being evaluated.  Each property must be evaluated individually and done so once for every instance of this type in every debugger display window. This set of evaluations is repeated on every single step. This can get very expensive if collections of this type end up getting displayed (imagine stepping with a couple thousand of these in the window!).

Please don't read this and remove every property from DebuggerDisplay's in your code. One property is very unlikely to cause a problem. Issues typically arise when many properties are used and collections of that type end getting displayed in the debugger windows.

## Do use property / field names instead of language specific expressions

Evaluation holes in the string are not limited to just properties and function calls. They can handle pretty much any legal expression you can dream up. In the past this has lead to developers putting all manner of expressions into DebuggerDisplay attributes. The most common being the use of ternary expressions

{% highlight csharp %}
[DebuggerDisplay("Count {IsEmpty ? 0 : Count}")]
{% endhighlight %}

While this works fine, please don't do this!?? DebuggerDisplay attributes are evaluated not by the language in which they were defined but by the expression evaluator of the language in which they are being used. The above works great but only when viewed in a C# application. It fails miserably when viewed in other languages like VB.Net (and when F# has their own EE it will fail for that as well).

While there is no truly universal expression one which is supported by most languages is member names. Having an expression which is a simple property or field goes a long way to removing this problem.  

## Don't evaluate expressions that throw exceptions

Earlier I mentioned that the most expensive action an expression evaluator performs is evaluating a function. The most expensive variant of evaluating a function are those which throw exceptions. Please don't do this.

## Don't use mutating properties or functions

Usually this goes without saying but I've seen enough examples of this to warrant an entry. Don't put expressions into DebuggerDisplay values which will mutate the underlying value. This will lead to only confusion.  

## Preferred Pattern

My personal preferred pattern for DebuggerDisplay attributes is to have the entire item be an expression: DebuggerDisplay. I then add a private instance property to my type named DebuggerDisplay and do all of my custom formatting in this property. Having the property be private is fine because [nothing is private in the debugger.](http://blogs.msdn.com/b/jaredpar/archive/2010/05/17/the-debugger-is-different.aspx)
    
{% highlight csharp %}
[DebuggerDisplay("{DebuggerDisplay,nq}")]
public sealed class Student {
    public string FirstName { get; set; }
    public string LastName { get; set; }
    private string DebuggerDisplay {
        get { return string.Format("Student: {0} {1}", FirstName, LastName); }
    }
}
{% endhighlight %}

The ',nq' suffix here just asks the expression evaluator to remove the quotes when displaying the final value (nq = no quotes).

I prefer this pattern because it's only requires a single function to be evaluated, I can still have language specific expressions (which are nicely type checked by the compiler) and it doesn't contribute to the public API of my type.

[1] Note the word 'I'. These are not any kind of official recommendations, just several I advocate to people using this feature.

[2] In one performance critical scenario for Visual Studio 2010 over 95% of it was spent evaluating the function!


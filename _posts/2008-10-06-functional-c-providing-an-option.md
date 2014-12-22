---
layout: post
title: Functional C#&#58; Providing an Option
---
Sorry for the terrible pun in the title. I wanted to blog about developing an F# style Option class for C# and I couldn't resist.

The basics of an Option class are very straight forward. It's a class that either has a value or doesn't. It's almost like nullable but for every type and allows for nulls to be a valid value. Here's a straight forward Option class I coded up.

``` csharp
public sealed class Option<T> {
    private readonly T m_value;
    private readonly bool m_hasValue;
    public static Option<T> Empty {
        get { return new Option<T>(); }
    }
    public bool HasValue {
        get { return m_hasValue; }
    }
    public T Value {
        get {
            if (!HasValue) {
                throw new InvalidOperationException("Option does not have a value");
            }
            return m_value;
        }
    }
    public Option(T value) {
        m_hasValue = true;
        m_value = value;
    }
    private Option() {
        m_hasValue = false;
        m_value = default(T);
    }
}

public sealed class Option {
    public static Option<T> Create<T>(T value) {
        return new Option<T>(value);
    }
}
```

I modified a bit of terminology to be more consistent with other frameworks I use (Some/None -> Value,HasValue). It's succinct, generic and has type inference friendly create functions. Or does it?

Lets consider a function which has a return type of Option<int>. Case 1 is Option with a value. There is a type inference friendly Option.Create method which makes for a simple return expression. No types needed.

    
``` csharp
Option<int> SomeMethod() {
    return Option.Create(42);
}
```

Now lets consider Case #2, None. Here there is no handy inference method because what would we use for inference. There is no variable with a Type to use so we are forced to be explicit about the type.

``` csharp
Option<int> SomeMethod2() {
    return Option<int>.Empty;
}
```

In this case we're not so bad off because we're dealing with a simple type.  But what about more complex types' Consider for example a hypothetical Unfold method. The termination expression would be Option<Tuple<int,string>>.Empty.  Anonymous types are even worse since they are unnamable and can not ever be the source of an option with this design. This really pales in the usage category when compared with F#.

Lets see if we can do better.

First we could consider a design where we have a static creation method Empty which takes variables that aren't ever used. This will give us the benefit of type inference but at the expense of an API which is faulty to the core. It forces the user to create parameters that aren't ever used. Definitely not a good design.

This leaves us with using a solution that doesn't involve variables of the necessary type. This essentially forces us into a non-generic solution since we need variables for type inference. This non-generic Option won't be compatible with our generic return type. But wait, what will the compiler do if two expressions have conflicting types' Eventually it will attempt to perform a conversion. So if we make our non-generic empty Option convertible to any generic empty Option we can use the compilers type safety to our advantage.

Definition a non-generic empty Option is straight forward.  

    
``` csharp
public sealed class Option {
    private static Option s_empty = new Option();
    private Option() {
    }
    public static Option Empty {
        get { return s_empty; }
    }
    public static Option<T> Create<T>(T value) {
        return new Option<T>(value);
    }
}
```

Using a private constructor allows us a high degree of confidence that any Option instance hanging around came from our Empty property and hence represents an empty option. Now all we need to do is define a conversion on Option<T>. Essentially we want to say that any non-generic Option is convertible to this instance. Add the following to Option<T>

``` csharp
public static implicit operator Option<T>(Option option) {
    return Option<T>.Empty;
}
```

Now, we can use an empty option in any generic scenario without having to specify ugly type parameters.
    
``` csharp
Option<int> SomeMethod3() {
    return Option.Empty;
}
```


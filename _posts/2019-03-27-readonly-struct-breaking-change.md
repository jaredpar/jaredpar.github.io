---
layout: post
title: Is making a struct readonly a breaking change?
tags: [c#, readonly, breaking change]
---

C# 7.2 added the ability to mark a `struct` declaration as `readonly`. This has the effect of guaranteeing that no 
member of the `struct` can mutate its contents as it ensures every field is marked as `readonly`. This guarantee is 
imporant because it allows the compiler to avoid defensive copies of `struct` values in cases where the underlying 
location is considered `readonly`. For example when invoking members of a `struct` which is stored in a 
`readonly` field. 

``` csharp
class Operation { 
    readonly string Name;
    readonly DateTimeOffset Started;

    public override string ToString() => Name + Started.ToString();
}
```

When calling `Started.ToString` here the compiler first creates a defensive copy of `Started` on the stack. The 
`ToString` operation is then invoked on that copy. The reason for this is the compiler must assume the worst case
which is `ToString` mutates the contents of the `struct` and hence violates the `readonly` contract on the field. 

Starting with netcoreapp2.1 though `DateTime`, and [many other types](https://github.com/dotnet/corefx/pull/24997),
are now marked as `readonly struct`. Invocations like the `ToString` above now occur directly on the field, avoiding
the wasteful copy it had before. 

These defense copies are small when looked at individually but can quickly add up to a significant performance issue. 
Particularly in high performance scenarios which make heavy use of `readonly` and tend to use larger sized `struct` 
declarations. Before the `readonly struct` feature these code bases often had to sacrifice correctness by avoiding
`readonly` to improve perforamnce by avoiding defensive copies. Now though the same code bases can have performance 
and without sacrificing correctness.

One question that frequently comes up with `readonly struct` though is whether or not this is a breaking change? The 
short answer is no. This is a very safe change to make. Adding `readonly` is not a source breaking change for 
consumers: it is still recognized by older compilers, it doesn't cause overload resolution changes, it can be used in 
other `struct` types, etc ... The only effect it has is that it allows the compiler to elide defensive copies in a
number of cases.

That being said there is one scenario to be careful of when applying this feature. One of the requirements is that every 
field of the type be explicitly marked as `readonly`. Adding `readonly` to a field as a part of making the containing
type `readonly` can cause observable behavior changes. When the field type is a non-readontly `struct` defensive copies 
will now be made for invocations and this can cause changes to be dropped where previously they were persisted. This 
has nothing to do with `readonly struct` but instead is a direct result of making the field `readonly`.

The CoreFX team ran into exactly this problem when making `Nullable<T>` into a `readonly struct`. The `T value` field 
was marked as `readonly` as a part of that process. This turned out to be 
[a breaking change](https://github.com/dotnet/corefx/pull/24997#issuecomment-346523578) because it meant operations 
like `value.ToString` now caused a defensive copy to occur which caused all mutations inside `value` to be discarded.
Eventually this lead to the change [being reverted](https://github.com/dotnet/coreclr/pull/15198) because of the high
impact of `Nullable<T>`. 

``` csharp
struct Nullable<T> { 
    readonly T value;
    bool hasValue;

    public override string ToString() {
        // Oops: value.ToString now creates a defensive copy
        return  hasValue ? value.ToString : "";
    }
}
```

Again though, this is about marking fields `readonly`, not the containing type. This type of problem is fairly rare
though. Even in code bases where compat is of incredibly high value there have been sweeping changes to 
[mark](https://github.com/dotnet/roslyn/pull/34478) [large](https://github.com/dotnet/corefx/pull/24997)
[blocks](https://github.com/dotnet/coreclr/pull/14789) of `struct` 
[instances](https://github.com/dotnet/corert/pull/4855) as `readonly`. 

The other case where behavior changes can occur has to do with aliasing. This is extremely rare though, only showing 
up in hypotheticals vs. actual code bases. It is best demonstrated by example:

``` csharp
struct S { 
    static S StaticField = new S(0);
    public static ref readonly S Get() => ref StaticField;

    public readonly int Field;
    public S(int field) {
        Field = field;
    }

    public int M(int value) {
        StaticField = new S(value);
        return Field;
    }

    static void Main() {
        Console.WriteLine(S.Get().M(42));
    }
}
```

This code will print `0`. The invocation of `M(42)` here occurs on a `ref readonly S` which means the receiver location
is conisdered `readonly`. This is the `ref` equivalent of invoking `M` when the receiver is contained in a 
`static readonly` field. The location itself is `readonly`, the member is not and hence the compiler creates a 
defensive copy. 

When the declaration is changed to `readonly struct S` the code will print `42`. The reason is that there is no longer
a defensive copy during the invocation of `M`. Defensive copies are all about ensuring the target method does not 
directly mutate the contents of the receiver. But it is still possible for other aliases to the same location to 
indirectly mutate the contents by assigning into the location.

This is a fairly contrived example though and not one that is likely to occur in many code bases. It is listed here 
not as a warning against using `readonly struct` but quite the opposite. It's meant to demonstrate the level of 
complication needed to observe the difference.

The take away here is `readonly struct` is a beneficial annotation, both for performance and correctness, that is 
very safe to add to your code base.
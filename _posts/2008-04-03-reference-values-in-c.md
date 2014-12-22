---
layout: post
---
Reference values are a powerful feature of C++ but I find they have one significant detractor.  A developer can not look at an API call and determine if a parameter is being passed by reference or value (VB has the same problem).

IMHO this is one item that C# got 100% correct.  In C# developers must say a value is out/ref or a compile error results.  Forcing both the API declaration and usage to specify the reference semantics makes code much more understandable.  When you look at an API call there is absolutely no question about the byref/byval/out semantics of a parameter.

Internally I've met people who are hesitant to use reference parameters in C++ because of the ambiguity.  Not making it declarative in both places meant unexpected behavior could occur in a number of scenarios.  I agree with this statement.

But hey we're talking about C++ here.  Any C++ problem can be fixed with some macros and a template right?  I thought about this over the weekend and came up with a quick sample.  Note, I haven't extensively tested this sample yet so there may be bugs.  However it gets the base cases right.

The goal of this API is to allow API authors to force developers to be explicit about their ByRef semantics.  It will prevent developers from silently passing a value by ref and hence getting unexpected behavior.  Failure to do so will result in a compile time error.  Also there is a minor bit of indirection overhead for debug mode but in retail this will compile out
to normal code.

``` c++
#ifdef DEBUG

template <typename T>
class ByRefType
{
public:
    explicit ByRefType(T& arg) : m_ref(arg)
    {
    }

    operator T&() const 
    {
        return m_ref;
    }

    ByRefType& operator=(const T& value)
    {
        m_ref = value;
        return *this;
    }

private:
    ByRefType();

    mutable T& m_ref;
};

template <typename T>
ByRefType<T> MakeByRefType(T& expr)
{
    return ByRefType<T>(expr);
}

#define ByRef(expr) MakeByRefType(expr)
#define ByRefParam(type) ByRefType<type> 

#else

#define ByRef(expr) expr
#define ByRefParam(type) type&

#endif
```

All well and good.  Now we can attribute byref paramaters with ByRefParam() and force callers to tag it as a ByRef argument.

``` c++
    void SimpleByRef(ByRefParam(int) i, int newValue)
    {
        i = newValue;
    }
    
    void Test()
    {
        int i1;
        SimpleByRef(ByRef(i1), 5);
        SimpleByRef(i1, 6);     // Compiler Error!!!
    }
```

As said before, this is an initial implementation and I expect updates as I use this in code and find bugs.  Please post back with any you find.


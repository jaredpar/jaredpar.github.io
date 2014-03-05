---
layout: post
---
ATL has a lot of great tools for COM programming and [CComPtr](http://msdn2.microsoft.com/en-us/library/ezzw7k98\(VS.80\).aspx) is a good example.  It's a smart pointer class which manages the reference count of an underlying COM object.

One of it's limitations though is it will only work properly when the inheritance chain for a class has only one path to IUnknown.  If it has more than one path, the following error will be issued when you attempt to assign a value of type T to the CComPtr.

    error C2594: 'argument' : ambiguous conversions from 'SomeClass *' to 'IUnknown *'  

The reason behind this is the operator= for CComPtr uses [AtlComPtrAssign](http://msdn2.microsoft.com/en-us/library/40d27a83\(vs.71\).aspx) to change the references.  The right hand side of the assignment is passed to this function as IUnknown.  Since there are multiple paths to IUnknown the C++ compiler cannot implicitly perform the cast and issues the above error.

I most frequently encounter this error in larger code bases with older classes.  New functionality is needed so I add a new interface and end up with a lot of C2594 errors.

To work around this I defined a new CComPtr class named CComPtrEx which inherits from CComPtr base.  It defines the same operators as CComPtr but uses a Copy Constructor and Swap to perform the = which gets around the multiple paths to IUnknown.  The rest of the functions are identical to CComPtr.

    
{% highlight csharp %}
template <class T>
class CComPtrEx : public CComPtrBase<T>
{
public:
    CComPtrEx() throw()
    {
    }
    CComPtrEx(int nNull) throw() :
        CComPtrBase<T>(nNull)
    {
    }
    CComPtrEx(T* lp) throw() :
        CComPtrBase<T>(lp)
    {
    }
    CComPtrEx(_In_ const CComPtrEx<T>& lp) throw() :
        CComPtrBase<T>(lp.p)
    {
    }

    T* operator=(_In_opt_ T* lp) throw()
    {
        if(*this!=lp)
        {
            CComPtrEx<T> sp(lp);
            Swap(&p, &sp.p);
        }
        return *this;
    }

    T* operator=(_In_ const CComPtrEx<T>& lp) throw()
    {
        if(*this!=lp)
        {
            CComPtrEx<T> sp(lp);
            Swap(&p, &sp.p);
        }
        return *this;
    }
};
{% endhighlight %}


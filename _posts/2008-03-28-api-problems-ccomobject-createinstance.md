---
layout: post
---
[CComObject::CreateInstance](http://msdn2.microsoft.com/en-us/library/9e31say1.aspx) is a light weight method for creating instances of COM objects in your code.  Unfortunately the design of the API makes it easy to introduce subtle errors into your code.  The two problems are it encourages manually ref counting and the object initially has a ref count of 0.  This means you must remember to AddRef before calling any other function. Neither of these ideas in themselves are bad but it leads to tedious, repetitive code that is too often done incorrectly.

Below is a typical example I see in code.
    
``` c++
void AMethod()
{
    CComObject<Student> *pStudent;
    if ( SUCCEEDED(CComObject<Student>::CreateInstance(&pStudent)) )
    {
        pStudent->AddRef();
        VerifyStudent(pStudent);
        pStudent->Release();
    }
}
```

As a result of the manual ref counting, this code is not exception safe.  If VerifyStudent or any API it calls throws, an instance of Student will be leaked.

The second problem I often see in code is the placement of the VerifyStudent function.  Occasionally I see methods like VerifyStudent called before the AddRef.  If you see this in your code immediately file a bug.  The problem is the ref count is 0 before you call AddRef.  It COM it should always be legal to AddRef/Release a COM object passed into your function.  In this case while legal it will destroy the instance of Student.  What's even worse is this bug can show up years after you code.

Real world example.  I created a class to wrap a couple of operations.  One of it's members was Student and as such I wrapped it in a CComPtr<> for ease of use.  Fired up the program and everything crashed.  Turns out an instance of Student was passed to a function that eventually created an instance of my object before AddRef was called (essentially move VerifyStudent up one line).  As soon as my new object died CComPtr<> called Release, moved the RefCount to 0 and destroyed the object.

Writing the correct code is repetitive and begs for a wrapper function.  Enter CreateWithRef

    
``` c++
template <class T>
static 
HRESULT CreateWithRef(T** ppObject)
{
    CComObject<T> *pObject;
    HRESULT hr = CComObject<T>::CreateInstance(&pObject);
    if ( SUCCEEDED(hr) )
    {
        pObject->AddRef();
        *ppObject = pObject;
    }

    return hr; 
}

void AMethod2()
{
    CComPtr<Student> pStudent;
    if ( SUCCEEDED(CreateWithRef(&pStudent)) )
    {
        VerifyStudent(pStudent);
    }
}
```

As you can see, using this function takes less typing that a normal CreateInstance due to using type inference.  It's also exception safer since the resource is managed.

This API still has one flaw.  It allows people to pass in a raw pointer and hence violate exception safety.  It could be improved by forcing a caller to pass in a class which supports [RAII](http://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization).  In this case a good choice is CComPtrBase<>.  I tend to prefer this design because it forces the caller to use safer code.  
    
``` c++
template <class T>
static 
HRESULT CreateWithRef2(CComPtrBase<T>& spPointer)
{
    CComObject<T> *pObject;
    HRESULT hr = CComObject<T>::CreateInstance(&pObject);
    if ( SUCCEEDED(hr) )
    {
        pObject->AddRef();
        spPointer.Attach(pObject);
    }

    return hr; 
}

void AMethod3()
{
    CComPtr<Student> pStudent;
    if ( SUCCEEDED(CreateWithRef2(pStudent)) )
    {
        VerifyStudent(pStudent);
    }
}
```


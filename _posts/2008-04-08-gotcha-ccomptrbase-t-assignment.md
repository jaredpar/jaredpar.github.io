---
layout: post
---
Today what started out as a crash due to a pure virtual call turned into
finding a gotcha in CComPtrBase<T>.  Essentially the code in question boiled
down to the following.  Can you spot the problem?

``` c++
void GetAStudent(CComPtrBase<T> &spStudent)
{
    CComPtr<Student> spLocal;
    // Do some operation to get a student
    spLocal = spStudent;
}
```

The problem isn't apparent until you look at the definition for CComPtrBase<T>::operater =.  See the problem?  Basically CComPtrBase<T>::operator= isn't explicitly defined.  This means that C++ will automatically implement [memberwise assignment.](http://msdn2.microsoft.com/en-us/library/x0c54csc\(VS.71\).aspx)  The RHS of the operator= will be a "const CComPtrBase<T>&".

CComPtr<T> derives from CComPtrBase<T> therefore it satisfies this and a memberwise assignment will occur.  We now have two smart pointers on the same value.  However the second smart pointer, CComPtrBase<T>, did not perform an AddRef.  So when both objects are destroyed there will be an extra Release and hopefully a crash.

The fix?

  1. Use CComPtr<T> or CComPtrEx<T> instead of CComPtrBase<T>
  2. Less Optimal: call AddRef() on spLocal.  


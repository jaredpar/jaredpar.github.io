---
layout: post
---
[IEnumerable(Of T)](http://msdn2.microsoft.com/en-us/library/9eekhta0.aspx) is a huge step up in the 2.0 framework from the original [IEnumerable](http://msdn2.microsoft.com/en-us/library/9eekhta0.aspx) interface.  It provides a typed enumeration which eliminates lots of nasty casts.  The best part is that IEnumerable(Of T) is backwards compatible with IEnumerable (it inherits from it).

What's frustrating is that IEnumerable is not forwards compatible with IEnumerable(Of Object).  This prevents you from using IEnumerable anywhere IEnumerable(Of Object) or an inferred IEnumerable<T> is expected even though they have almost the same interface. The framework couldn't take the same approach and have IEnumerable inherit IEnumerable(Of Object) because it would have broken any implementer on upgrade to the 2.0 framework.

The good news is this is easy to shim.  Since IEnumerable(Of Object) and IEnumerable have virtually the same, it's easy to create a wrapper class that forwards the calls into the base enumerator.

The basic shim involves two classes

* EnumerableShim - Implements IEnumerable(Of Object).  This class wraps an IEnumerable object only has two methods. 
    
``` vbnet
        Public Function GetEnumerator() As System.Collections.Generic.IEnumerator(Of Object) Implements System.Collections.Generic.IEnumerable(Of Object).GetEnumerator
            Return New EnumeratorShim(m_enumerable.GetEnumerator())
        End Function
    
        Public Function GetEnumerator1() As System.Collections.IEnumerator Implements System.Collections.IEnumerable.GetEnumerator
            Return m_enumerable.GetEnumerator()
        End Function
```

* EnumeratorShim - Implements IEnumerator(Of Object).  This class wraps the IEnumerator object created above and implements the standard methods by forwarding all calls to the IEnumerator implementation.  For example ...
    
``` vbnet
Public ReadOnly Property Current() As Object Implements System.Collections.Generic.IEnumerator(Of Object).Current
    Get
        Return m_impl.Current
    End Get
End Property
```

Now whenever your stuck with and old framework collection that was not updated for generic support, you can use it in generic situations with a single indirection call.  
    
``` vbnet
Dim list As New ArrayList
...
SomeMethod(New EnumerableShim(list))
```


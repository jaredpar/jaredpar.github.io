---
layout: post
---
After my recent postings on the [rules of Equality]({% post_url 2008-04-28-properly-implementing-equality-in-vb %}), I thought it would be a good idea to post a simple example of equality.  The class in question, Example, has only one field of type Integer name m_field1.  Two instances of Example are equal if m_field1 has the same value.  So the real equality check is just a single Integer comparison.

Unfortunately, as my posts alluded to, even though the check is simple getting it right is not necessarily so.  The equality portion of example takes roughly 20 lines of code while the actual equality check represents only 1 of those lines [^1].  Not a good ratio.  The good and bad news about the other 19 lines is they are boiler plate so once you know them you don't have to think about them.  For my own purposes I've converted those 19 lines into a snippet which automates the process but doesn't make it any easier on the eye.

``` vb
Class Example
    Implements IEquatable(Of Example)

    Private ReadOnly m_field1 As Integer
    Public Sub New(ByVal field As Integer)
        m_field1 = field
    End Sub

    Public Function Equals1(ByVal other As Example) As Boolean Implements System.IEquatable(Of Example).Equals
        If other Is Nothing Then
            Return False
        End If

        Return m_field1 = other.m_field1
    End Function

    Public Overrides Function Equals(ByVal obj As Object) As Boolean
        Return Equals1(TryCast(obj, Example))
    End Function

    Public Overrides Function GetHashCode() As Integer
        Return m_field1.GetHashCode
    End Function

    Public Shared Operator =(ByVal left As Example, ByVal right As Example) As Boolean
        Return EqualityComparer(Of Example).Default.Equals(left, right)
    End Operator

    Public Shared Operator <>(ByVal left As Example, ByVal right As Example) As Boolean
        Return Not EqualityComparer(Of Example).Default.Equals(left, right)
    End Operator

End Class

Module Module1

    Sub AssertTrue(ByVal cond As Boolean)
        Debug.Assert(cond, "failure")
    End Sub

    Sub AssertFalse(ByVal cond As Boolean)
        Debug.Assert(Not cond, "failure")
    End Sub

    Sub Main()
        Dim v1 As New Example(1)
        Dim v2 As New Example(2)
        Dim v3 As New Example(1)

        AssertFalse(v1 Is v2)
        AssertFalse(v1 Is v3)
        AssertTrue(v1 Is v1)
        AssertFalse(v1 = v2)
        AssertTrue(v1 = v3)
        AssertFalse(v1 = Nothing)
        AssertFalse(Nothing = v1)
        AssertTrue(v1 <> v2)
        AssertTrue(v1 <> Nothing)
        AssertTrue(EqualityComparer(Of Example).Default.Equals(v1, v3))
        AssertFalse(EqualityComparer(Of Example).Default.Equals(v1, v2))
    End Sub

End Module
```

[^1]: Before VB criticism enters, C# has roughly the same ratio for the same sample.


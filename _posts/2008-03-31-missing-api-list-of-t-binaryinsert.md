---
layout: post
---
One API that seems to be missing from [List(Of T)](http://msdn2.microsoft.com/en-us/library/6sh2ey19.aspx) is a BinaryInsert method. Especially since there is already a [BinarySearch](http://msdn2.microsoft.com/en-us/library/3f90y839.aspx) method.

Binary insert is a method for inserting a value into an already sorted list.  Since the list is already sorted we can do a binary search to find the appropriate place to insert. The insert keeps the list sorted so the cost of a binary insert is just the cost of the search which is O(Log(N)).  

An alternative method for keeping a sorted list sorted is to insert and then resort. Most sorting algorithms have a cost of O(N*Log(N)). In other words it's N times more expensive.

Yet this API doesn't exist. No matter. We can quickly fix this problem with a couple of extension methods.

``` vbnet
Public Module Extensions

    <Extension()> _
    Public Sub BinaryInsert(Of T)(ByVal list As List(Of T), ByVal value As T, ByVal comp As IComparer(Of T))
        list.BinaryInsert(value, comp, 0, list.Count)
    End Sub

    <Extension()> _
    Public Sub BinaryInsert(Of T)(ByVal list As List(Of T), _
                                  ByVal value As T, _
                                  ByVal comparer As IComparer(Of T), _
                                  ByVal iStart As Integer, _
                                  ByVal iEnd As Integer)
        While iStart < iEnd
            Dim len = iEnd - iStart
            Dim iMiddle = iStart + (len \ 2)
            Dim comp = comparer.Compare(value, list(iMiddle))
            If 0 = comp Then
                iStart = iMiddle
                Exit While
            ElseIf comp < 0 Then
                iEnd = iMiddle
            Else
                iStart = iMiddle + (len Mod 2)
            End If
        End While
        list.Insert(iStart, value)
    End Sub

End Module
```


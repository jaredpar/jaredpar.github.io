---
layout: post
---
[Previously]({% post_url 2008-03-31-missing-api-list-of-t-binaryinsert %}) I discussed a potential missing API in List(Of T).BinaryInsert.  One of the items I mentioned was it had better performance because it was O(Log N) vs Insert and Sort which is O(NLogN).  Several users correctly pointed out this was incorrect and that Insert() had the additional overhead of an Array.Copy() which is O(N)ish.  But most agreed O(N) + O(LogN) was better than O(NLogN).

Given that I already missed a key portion, I decided to write a test program to try out the various methods.  Caveat: I'm not a performance guy.  While I find performance intriguing and interesting it is by no means my specialty.  Any single performance test is unlikely to capture all real world scenarios.  However I did find the results a bit surprising.  At the bottom of the post is the test code I wrote.

Here is the summary output.

    Force Jit  
    BinaryInsert:     00:00:00.0051167  
    Insert Then Sort: 00:00:00.0000251  
    Range (0-99)  
    BinaryInsert:     00:00:00.0000266  
    Insert Then Sort: 00:00:00.0000316  
    Random 10  
    BinaryInsert:     00:00:00.0000053  
    Insert Then Sort: 00:00:00.0000034  
    Random 100  
    BinaryInsert:     00:00:00.0000294  
    Insert Then Sort: 00:00:00.0000235  
    Random 1000  
    BinaryInsert:     00:00:00.0004917  
    Insert Then Sort: 00:00:00.0001526  
    Random 10000  
    BinaryInsert:     00:00:00.0261899  
    Insert Then Sort: 00:00:00.0018287  
    Random 100000  
    BinaryInsert:     00:00:02.4289054  
    Insert Then Sort: 00:00:00.0237019

As you can see, based on my sample program, BinaryInsert is much slower than Insert and Sort.  I ran the profiler against this and verified the suspicion that List(Of T).Insert() took the vast majority of the time.

Perhaps there is a reason BinaryInsert is missing.
    
{% highlight vbnet %}
Module Module1

    Function BinaryInsert(Of T)(ByVal enumerable As IEnumerable(Of T), ByVal comp As IComparer(Of T)) As TimeSpan
        Dim list As New List(Of T)
        Dim watch As New Stopwatch()

        watch.Start()
        For Each value In enumerable
            list.BinaryInsert(value, comp)
        Next
        watch.Stop()
        Return watch.Elapsed
    End Function

    Function InsertAllThenSort(Of T)(ByVal enumerable As IEnumerable(Of T), ByVal comp As IComparer(Of T)) As TimeSpan
        Dim list As New List(Of T)
        Dim watch As New Stopwatch()

        watch.Start()
        For Each value In enumerable
            list.Add(value)
        Next
        list.Sort(comp)
        watch.Stop()
        Return watch.Elapsed
    End Function

    Sub TestBoth(Of T)(ByVal title As String, ByVal enumerable As IEnumerable(Of T))
        TestBoth(title, enumerable, Comparer(Of T).Default)
    End Sub

    Sub TestBoth(Of T)(ByVal title As String, ByVal enumerable As IEnumerable(Of T), ByVal comp As IComparer(Of T))
        Dim copy = New List(Of T)(enumerable)
        Dim ellapsedBinary = BinaryInsert(New List(Of T)(copy), comp)
        Dim ellapsedSort = InsertAllThenSort(New List(Of T)(copy), comp)

        Console.WriteLine(title)
        Console.WriteLine("BinaryInsert:     {0}", ellapsedBinary)
        Console.WriteLine("Insert Then Sort: {0}", ellapsedSort)
    End Sub

    Function Range(ByVal start As Integer, ByVal count As Integer) As List(Of Integer)
        Dim list = New List(Of Integer)
        For i = start To count - 1
            list.Add(i)
        Next
        Return list
    End Function

    Function Random(ByVal count As Integer) As List(Of Integer)
        Dim rand As New Random()
        Dim list = New List(Of Integer)
        For i = 0 To count - 1
            list.Add(rand.Next())
        Next
        Return list
    End Function

    Sub Main()
        TestBoth("Force Jit", New Integer() {1})
        TestBoth("Range (0-99)", Range(0, 100))
        TestBoth("Random 10", Random(10))
        TestBoth("Random 100", Random(100))
        TestBoth("Random 1000", Random(1000))
        TestBoth("Random 10000", Random(10000))
        TestBoth("Random 100000", Random(100000))
    End Sub

End Module
{% endhighlight %}

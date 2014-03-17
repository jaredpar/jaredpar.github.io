---
layout: post
---
This is part 3 of a series.  You can find [part one here]({% post_url 2005-07-11-marshaling-nested-data-structures-part-1 %}).  Please refer to that article for all of the Native definitions of the structures that I use here.

In part 2 of this series I demonstrated how you can Marshal nested data structures by flattening an array of structures into it's individual elements.  Using this is very awkward and is only practical when the size of your array is small.  This installment will get around these limitations with a bit of Marshalling help.  We'll get back indexing and remove the awkward flattening.

Once again, don't forget that the only 2 things that matter when Marshalling data

  1. Byte Size 
  2. Byte Layout 

When an array of structures are declared as a member of a struct, in the same manner as the Course structure, the data is inlined after the first two ints.  We can get this data to Marshall properly by inserting a structure with the same size as the array of Students.  The Native Student Structure is 52 bytes so we need a 260 byte structure.  The following will do.

{% highlight csharp %}
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode, Size = 260 )]
public struct ArrayBlob
{
}

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct Course
{
    public int Id;
    public int Count;
    public ArrayBlob Blob;

    /* ... Methods ... */
}
{% endhighlight %}


This structure meets all of our requirments.  Course is now properly formatted and can be Marshalled back and forth successfully.  However our student array is stuck in a chunk of data that has no access methods.  This blob is just an array of students in memory.  Getting the Students out in C would be a snap.  We could just grab the address, cast it the the appropriate pointer and run away with the Student elements.

{% highlight c++ %}
Student *elements = (Student*)(&(myCourse.Blob); 
{% endhighlight %}

Unfortunately I'm giving these examples in Safe code so this is not allowed.  You can get the same effect with C# although it's a bit slower and forces a memory allocation. We implement this as in indexer into the Course struct.

{% highlight csharp %}
public Student this[int index]
{
    get
    {
        if ( index >= Count )
        {
            throw new ArgumentOutOfRangeException();
        }

        IntPtr ptr = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(ArrayBlob)));
        try
        {
            Marshal.StructureToPtr(this.Blob, ptr, false);
            int offset = index * Marshal.SizeOf(typeof(Student));
            IntPtr structPtr = new IntPtr(ptr.ToInt32() + offset);
            return (Student)Marshal.PtrToStructure(structPtr, typeof(Student));
        }
        finally
        {
            Marshal.FreeHGlobal(ptr);
        }
    }
}
{% endhighlight %}

Some error checking was removed for brevity sake.  Granted this is still a suboptimal way of accessing the members of the structure.  Every index requires an allocation.  But if you only interop for brief times and in non perf sensitive areas this code will do just fine.  Here's an example.

    
{% highlight csharp %}
public static class Enrollment
{
    [DllImport("Enrollment.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr CreateStudent(
        [MarshalAs(UnmanagedType.LPWStr)] String firstName,
        [MarshalAs(UnmanagedType.LPWStr)] String lastName,
        int bDay,
        int bMon,
        int bYear);

    [DllImport("Enrollment.dll", CharSet = CharSet.Unicode)]
    public static extern void UpdateStudentInfo(
        [MarshalAs(UnmanagedType.LPWStr)] String firstName,
        [MarshalAs(UnmanagedType.LPWStr)] String lastName,
        int bDay,
        int bMon,
        int bYear,
        ref Student student);

    [DllImport("Enrollment.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr GetCourseInfo(int id);
}


class MarshalFun
{
    static void Main(string[] args)
    {
        IntPtr ptr = Enrollment.GetCourseInfo(42);
        Course course = (Course)Marshal.PtrToStructure(ptr, typeof(Course));

        Student first = course[0];
        Student second = course[1];
    }
}
{% endhighlight %}

This code assumes that at least 2 students were returned from GetCourseInfo().  This code is much cleaner than the previous example.  It will also work with very large sized arrays.  However it does have undue perf and memory overhead.  Next time we'll look at a way to have the clean code and remove all of the perf problems present in the current code.

This posting is provided "AS IS" with no warranties, and confers no rights.  Use of included script samples are subject to the terms specified at **<http://www.microsoft.com/info/cpyright.htm>**.


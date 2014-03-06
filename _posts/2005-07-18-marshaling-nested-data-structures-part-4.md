---
layout: post
---
This is part 4 of a series.  You can find **[part one here**](http://blogs.msdn.com/jaredpar/archive/2005/07/11/437584.aspx).  Please refer to that article for all of the Native definitions of the structures that I use here.

In the previous article we were left with a solution where using the code was very clean but the actualy implementation had extra allocation and perf overhead.  We'll conquer both of those in this installment by implementing a custom marshaler for our Course object.  This is accomplished by implementing ICustomMarshaler and call the class CourseMarshaler.  [(ICustomMarshaler docs)](http://msdn.microsoft.com/library/default.asp?url=/library/en-us/cpref/ html/frlrfsystemruntimeinteropservicesicustommarshalermemberstopic.asp)

Custom marshaling is exactly like it sounds.  The marshaler itself does practically nothing.  Your code must transform the managed data structure into a native format and vice versa.  It can be tedious at times but this method can be used to marshal even the most complex of structures.  There are 6 methods you must implement.  Lets go over each of them.

CleanupData() - Use this method to dispose of anything on your managed object when it's no longer needed.  Typically there is nothing to do here and this method remains blank as it does in our case.

CleanupNativeData() \- Use this method to free up any data associated with the Native pointer after the runtime is finished using it.  In our case, we have to allocate memory to Marshal the data structure into, so we need to free up this pointer.

{% highlight csharp %}
public void CleanUpNativeData(IntPtr pNativeData)
{
    Marshal.FreeCoTaskMem(pNativeData);
}
{% endhighlight %}

GetNativeDataSize() - Returns the size of the unmanaged data structure.  As previously discussed, this size is 268.

MarshalManagedToNative() - Takes in an object and returns a pointer to the memory that contains the Native structure in memory.  To complete this we need to allocate a block of memory, and then marshal each of the fields in order into that memory block and return the pointer to the front of the block.  The pointer we allocate will be freed later when the runtime passes it into CleanupNativeData().  Some error checking was removed for the sake of brevity.

{% highlight csharp %}
public IntPtr MarshalManagedToNative(object managedObj)
{
    Course course = (Course)managedObj;

    IntPtr ptr = Marshal.AllocCoTaskMem(this.GetNativeDataSize());
    if (IntPtr.Zero == ptr)
    {
        throw new Exception("Could not allocate memory");
    }

    // Write the Int values in order into memory
    Marshal.WriteInt32(ptr, 0, course.Id);
    Marshal.WriteInt32(ptr, Marshal.SizeOf(typeof(Int32)), course.Count);
            
    // Now we need to Marshal each of the Student elements into the "array".  This 
    // starts immediately after the Ints
    IntPtr cur = new IntPtr(ptr.ToInt32() + (2 * Marshal.SizeOf(typeof(Int32))));
    for (int i = 0; i < course.Count; i++)
    {
         Student student = course.Students[i];
         Marshal.StructureToPtr(student, cur, false);
         cur = new IntPtr(cur.ToInt32() + Marshal.SizeOf(typeof(Student)));
    }
    return ptr;
}
{% endhighlight %}

MarshalManagedToNative() - Marshal the Native Struct into a managed version.  This is almost identical to the sample that we did in part 3.  Code reposted below.  
    
{% highlight csharp %}
public object MarshalNativeToManaged(IntPtr ptr)
{
    int courseId = Marshal.ReadInt32(ptr);
    int count = Marshal.ReadInt32(ptr, Marshal.SizeOf(typeof(Int32)));

    // Set the int values
    Course course = new Course();
    course.Id = courseId;
    course.Count = count;

    // Now read out the Student structures
    ptr = new IntPtr(ptr.ToInt32() + (2 * Marshal.SizeOf(typeof(Int32))));
    for (int i = 0; i < count; i++)
    {
        Student student = (Student)Marshal.PtrToStructure(ptr, typeof(Student));
        course.Students[i] = student;
        ptr = new IntPtr(ptr.ToInt32() + Marshal.SizeOf(typeof(Student)));
    }

    return course;
}
{% endhighlight %}

GetInstance() - This method is not a part of the ICustomMarshal interface but
it's a **static** method that must be implemented by any custom marashaler.
The runtime uses this to create an instance of the object.

Now we have a complete implementation of ICustomMarshal.  Really the only new
method that we had to implement was MarshalManagedToNative() and that's just
the opposite of what we did in part 3.  There are a couple of tidbits left
that we have to alter.

The first is that we **must** convert the managed Course from a struct to a class.  This is very important.  A custom marshaler can only be applied to reference types.  Changing Course to a class has a couple of other implications as well.  Structs in C# are stored in the stack and reference types are stored on the heap.  This has implications to Marshalling as well.  When you Marshal a struct (or any ValueType), the runtime is expecting to find a stack based value (or better, a non pointer value) on the Native end.  Now we are Marshalling a reference type so the runtime will expect to find a pointer value on the other end.

Also we can do away with the StructLayout attribute on the Course type.  We are hand Marshaling this now so we don't need to provide any hints to the runtime.  Now we are left with just a vanilla class.

{% highlight csharp %}
public class Course
{
    public int Id;  
    public int Count;  
    public List<Student> Students = new List<Student>(5);
}
{% endhighlight %}

Now we just need to inform the runtime about how to link our custom marshaler (called CourseMarshaler in my code) to the Course class.  Every place that we declare a P/Invoke method we need to add custom Marshalling data.  This is done by adding the MarshalAs attribute.  Lets use the GetCourseInfo() method for an example.  Here is our updated definition.

{% highlight csharp %}
[DllImport("Enrollment.dll", CharSet = CharSet.Unicode)]
[return: MarshalAs(UnmanagedType.CustomMarshaler, MarshalTypeRef=typeof(CourseMarshaler))]
public static extern Course GetCourseInfo(int id);
{% endhighlight %}

We've made two important changes here as well.  The first is we changed the return type of the method from an IntPtr to a Course.  Remember that this is a class now so the runtime is expecting a pointer value.  We take advantage of that here.  Also we've added the MarshalAs attribute to the return type to tell the runtime to use the Custom marshaler that we created.

This makes the use code even cleaner since we aren't dealing with an IntPtr return type anymore.

{% highlight csharp %}
static void Main(string[] args)
{
    Course course = Enrollment.GetCourseInfo(42);
    Student first = course.Students[0];
}
{% endhighlight %}

That essentially concludes this series on Marshalling Nested Data Structures.  I may add an additional chapter on common tips for debugging common marshalling problems if I have some time.  Hope you enjoyed this.

This posting is provided "AS IS" with no warranties, and confers no rights.  Use of included script samples are subject to the terms specified at **<http://www.microsoft.com/info/cpyright.htm>**.


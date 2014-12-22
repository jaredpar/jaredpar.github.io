---
layout: post
---
This is part 2 of a series.  You can find [part one here]({% post_url 2005-07-11-marshaling-nested-data-structures-part-1 %}).  Please refer to that article for all of the Native definitions of the structures that I use here.

The most important thing to remember when Marshalling data is that the .Net Runtime really only cares about byte layout and how many bytes you are trying to move.  If you mangle your managed structure to match the byte size and layout of your unmanaged structure, the runtime will Marshal it sucessfully almost all of the time.  Note by successfully I mean that the method will complete without causing the dreaded AccessViolationException but the data might not be quite what you were expecting.

For example.  Here is the typical managed definition for the Student struct definition.


``` csharp
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct Student
{
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 10)]
    public string FirstName;

    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 10)]
    public string LastName;

    public int BirthDay;
    public int BirthMonth;
    public int BirthYear;
}
```

Notice that the size of this structure is 52 bytes.

* FirstName 2 (size of char) * 10 (size of array) 
* LastName 2 (size of char) * 10 (size of array) 
* 12 bytes (4 bytes for each of the int's)

This is the same size as the native definiton of Student.  In memory these bytes will all appear in order with no spaces between them (FirstName and LastName are set as ByValTStr's so they will be inlined).  So LastName is 20 bytes offset of a student structure, BirthDay is 40 bytes offset and so on.

You don't always have to be so perfect though.  In this case it's only important because we want to accesss the fields of the managed structure.  If this was not important to us, we could have just as easily declared the structure as so.  
``` csharp
[StructLayout(LayoutKind.Sequential, Size = 52, CharSet = CharSet.Unicode)]
public struct Student
{ 

}
```

Note that i didn't leave anything out in the structure above.  It has the correct CharSet and Size so this could be successfully used wherever we need the Student structure.  It just doesn't help us very much in Managed code :)

Now onto the Course.  A lot of developers get tripped up when trying to define structs like Course in managed code.  Don't forget, all we need to do is get the bytes correct and the Marshaller will work out the rest.  

This structure is very small.  There are only 5 inlined elements in the student array.  This means that we could easily define our structure as so.  

``` csharp
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct Course
{
    public int Id;
    public int Count;
    Student Student0;
    Student Student1;
    Student Student2;
    Student Student3;
    Student Student4;
}
```


I realize there are several downsides to defining our structure like this.  For one, it doesn't look very clean.  Secondly we've lost the ability to easily index the array of students.  Also this works easily because there are only 5 elements in the array.  If there were much more than that this wouldn't be pheasible at all.  However this structure is layed out exactly like the one defined in Native code so this will Marshal correctly.

The next part to this series will try to make things a bit more pleasing to the eye. We'll get back indexing at the cost of a bit of manual Marshalling.

This posting is provided "AS IS" with no warranties, and confers no rights.  Use of included script samples are subject to the terms specified at **<http://www.microsoft.com/info/cpyright.htm>**.


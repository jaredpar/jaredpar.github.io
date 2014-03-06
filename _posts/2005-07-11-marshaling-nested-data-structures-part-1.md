---
layout: post
---
A frequent question that pops up on newsgroups such as microsoft.dotnet.framework.interop is how to Marshal nested structures (and arrays of nested structures) via P/Invoke.  The documentation on the subject that I have found usually only covers structures that defined in the UnmanagedType enumeration and just touch on the idea of structures containing nested arrays of custom structures.  Part of the reason is that the explinations for these problems is quite involed and scenario specific.  After answering it a few times I decided to make a multi part blog post on the subject.  This will consist of at least 4 entries (might add some more if something comes up).

Index

* [Part Two](http://blogs.msdn.com/jaredpar/archive/2005/07/12/437686.aspx)
* [Part Three](http://blogs.msdn.com/jaredpar/archive/2005/07/14/439024.aspx)
* [Part Four](http://blogs.msdn.com/jaredpar/archive/2005/07/18/439457.aspx)

The first installment is just going to be laying out our Native data structures that will be used throughout this series.  I'm going to use a generic(and quite contrived) university classroom examle.  Here are the C struct definitions and a couple of functions that I will be using.

    
{% highlight c++ %}
struct Student 
{ 
  WCHAR FirstName[10]; 
  WCHAR LastName[10]; 
  int BirthDay; 
  int BirthMonth; 
  int BirthYear; 
}; 

struct Course{ 
  int Id; 
  int Count; 
  Student Students[5]; 
}; 

    // Create a student with the specified information.  Returned structure should be freed with 
    // GlobalFree
__declspec(dllexport) Student* CreateStudent(
    LPCWSTR firstName, 
    LPCWSTR lastName, 
    int bDay, 
    int bMon, 
    int bYear)

    // Update an existing student with the specified information
__declspec(dllexport) void UpdateStudentInfo(
    LPCWSTR firstName, 
    LPCWSTR lastName, 
    int bDay, 
    int bMon, 
    int bYear, 
    Student *student)

    // Get information for a particurlar course.  Returned structure should be freed with 
    // GlobalFree
__declspec(dllexport) Course *GetCourseInfo(int courseId)
{% endhighlight %}

The environment I am coding and testing my fixes in is Microsoft Visual Studio 2005 Beta 2. All of these examples should work in all versions of Visual Studio though.  If you find an inconsistencies please let me know.  All native examples will also be in Unicode.

This posting is provided "AS IS" with no warranties, and confers no rights.  Use of included script samples are subject to the terms specified at **<http://www.microsoft.com/info/cpyright.htm>**.


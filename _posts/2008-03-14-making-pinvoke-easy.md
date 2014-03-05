---
layout: post
---
I very excited to announce we recently released a tool I've been working on to MSDN that will greatly help with using PInvoke in managed code.  The tool is called the "PInvoke Interop Assistant" and is included as part of a MSDN article on marshalling data for PInvoke and Reverse PInvoke scenarios.

Here is a link to the article and tool

  * Article: <http://msdn2.microsoft.com/en-us/magazine/cc164193.aspx>
  * Tool: [CLRInsideOut2008_01.exe](http://download.microsoft.com/download/f/2/7/f279e71e-efb0-4155-873d-5554a0608523/CLRInsideOut2008_01.exe)

The motivation behind this tool is writing PInvoke is a hard and often tedious task. There are many rules you must obey and many exceptions that must be taken into account.  Anything beyond simple data structures gets very involved and subtle semantics of C can greatly change the needed signature.  Incorrect translations often result in obscure exceptions or crashes.

In short, it's not any fun.

The tool works in several different ways to make PInvoke generation an easier process.  The goal is to make generating managed code for structs, unions, enums, constants, functions, typedefs , etc ... as easy as possible. The resulting code can be generated in both VB and C#.  

The GUI version of the tool operates in 3 modes.  

  1. SigImp Search: Search for a commonly used function and translate it into managed code. 
  2. SigImp Translate Snippet: Directly translate C code into managed PInvoke signatures. 
  3. SigExp: Convert managed binaries into C++ Reverse PInvoke scenarios

The first two are the parts I worked on and represent the PInvoke scenarios.  The third part was written by Ladi Prosek and will be covered in a different article. We chose the names SigImp and SigExp to mirror the tblimp/tlbexp tool base since they have similar functions.

### Directly translating C code into PInvoke Signatures

Most adventures in PInvoke start with a developer having a small set of C code they would like to use from a managed binary.  Typically it's one or two functions with several supporting C structs.  Before, all of this would be hand translated into managed code from scratch.  With this tool all you must do is paste the code into the tool and it will generate the interop signature for you.

For instance assume you wanted to translate the following C code into VB.

{% highlight c %}
struct S1
{
  int a;
  char[10] b;
};

float CalculateData(S1* p);
{% highlight csharp %}

Start up the tool and switch to the "SigImp Translate Snippet" tab.  Then paste the code in and then hit the Generate button.

![PInvoke1](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/MakingPInvokeEasy_E069/PInvoke1_thumb_1.png)

You can also set click the "Auto Generate" box and watch the code update as you type.

This translation is not limited to built-in C types.  It will also resolve most commonly used windows types such as HANDLE, DWORD all the way up to complex structs such as [WIN32_FIND_DATA](http://msdn2.microsoft.com/en-us/library/aa365740\(VS.85\).aspx)

### Searching for a commonly used function

Often developers want to use C functions familiar to them in managed code.  This can be a tedious task as well because if the signature is not already available you are back to coding from scratch.  Even adding a constant value can be tricky if you don't know which header file to look in.

The tool also provides a database of many commonly used functions, structs, constants, etc ... It is essentially anything that is included from windows.h.  Switch to the SigImp search tab, type the name of what you are looking for and hit generate.  For example if I want to see the value for WM_PAINT just type it in.

![Pinvoke2](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/MakingPInvokeEasy_E069/Pinvoke2_thumb.png)

In addition this part of the tool will also do dependency calculation.  For instance if choose a method which has a parameter that is a C structure it will automatically generate the structure with the function.  For instance if you choose the function [FindFirstFile](http://msdn2.microsoft.com/en-us/library/aa364418.aspx) it will determine that the function depends on the WIN32_FIND_DATA structure.  Furthermore it will notice that WIN32_FIND_DATA depends on FILETIME and generate both in addition to the method.

    
{% highlight vbnet %}
<System.Runtime.InteropServices.StructLayoutAttribute( _
    System.Runtime.InteropServices.LayoutKind.Sequential, _
    CharSet:=System.Runtime.InteropServices.CharSet.[Unicode])> _
Public Structure WIN32_FIND_DATAW
    '''DWORD->unsigned int
    Public dwFileAttributes As UInteger
    '''FILETIME->_FILETIME
    Public ftCreationTime As FILETIME
    '''FILETIME->_FILETIME
    Public ftLastAccessTime As FILETIME
    '''FILETIME->_FILETIME
    Public ftLastWriteTime As FILETIME
    '''DWORD->unsigned int
    Public nFileSizeHigh As UInteger
    '''DWORD->unsigned int
    Public nFileSizeLow As UInteger
    '''DWORD->unsigned int
    Public dwReserved0 As UInteger
    '''DWORD->unsigned int
    Public dwReserved1 As UInteger
    '''WCHAR[260]
    <System.Runtime.InteropServices.MarshalAsAttribute( _
        System.Runtime.InteropServices.UnmanagedType.ByValTStr, SizeConst:=260)> _
    Public cFileName As String
    '''WCHAR[14]
    <System.Runtime.InteropServices.MarshalAsAttribute( _
        System.Runtime.InteropServices.UnmanagedType.ByValTStr, SizeConst:=14)> _
    Public cAlternateFileName As String
End Structure

<System.Runtime.InteropServices.StructLayoutAttribute( _
    System.Runtime.InteropServices.LayoutKind.Sequential)> _
Public Structure FILETIME
    '''DWORD->unsigned int
    Public dwLowDateTime As UInteger
    '''DWORD->unsigned int
    Public dwHighDateTime As UInteger
End Structure

Partial Public Class NativeMethods
    '''Return Type: HANDLE->void*
    '''lpFileName: LPCWSTR->WCHAR*
    '''lpFindFileData: LPWIN32_FIND_DATAW->_WIN32_FIND_DATAW*
    <System.Runtime.InteropServices.DllImportAttribute("kernel32.dll", EntryPoint:="FindFirstFileW")> _
    Public Shared Function FindFirstFileW( _
        <System.Runtime.InteropServices.InAttribute(), _
            System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)> _
            ByVal lpFileName As String, _
        <System.Runtime.InteropServices.OutAttribute()> _
        ByRef lpFindFileData As WIN32_FIND_DATAW) As System.IntPtr
    End Function
End Class
{% endhighlight %}

### Translating Large Code bases

The snippet translator works well for small snippets of code.  If you are trying to translate a much larger code base, say several interdependent header files the small snippet dialog won't work well.  To work with larger code bases you should use the command line version of the tool;  sigimp.exe.  It is designed to process several header files and produce a mass output.

### Wrapping Up

This tool started out as a pet project of mine some time ago.  I'm extremely excited that customers are now going to be able to take advantage of it and I greatly look forward to any feedback you have.  I will post a couple more articles in the future detailing how this tool works under the hood.


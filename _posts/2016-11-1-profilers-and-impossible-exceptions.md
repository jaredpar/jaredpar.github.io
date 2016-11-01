---
layout: post
title: Profilers and impossible exceptions
tags: [watson]
---

At first glance some customer crash reports look simply impossible.  The code in question is so throughly tested or on such a common code path that it simply can't be broken.  If it were broken customers would be breaking your inbox with crash reports.

Deeper inspection though almost always reveals that indeed it is a bug in the code.  Perhaps there is a race condition, a machine configuration issue, a quirk of the OS / BCL the developer was unaware of.  Or even more simply, usually in the case of the original author inspecting the code, there is just a straight forward case that was overlooked. 

On occasion though no matter how deeply you look at the code the bug report seems genuinely impossible.  For example code which throws a NullReferenceException on a path where a null value is impossible.  The report indicates a crash but no matter how much you and others look at the code,you just can’t see a way that crash could happen. 

Take this particular [GitHub issue](https://github.com/dotnet/roslyn/issues/12993) as an example.  The customer presented us with the following call stack:
 
``` txt
Unhandled Exception: System.NullReferenceException: Object reference not set to an instance of an object.
   at Microsoft.CodeAnalysis.CompilationOptions.get_Errors()
   at Microsoft.CodeAnalysis.CSharp.CSharpCommandLineParser.Parse(IEnumerable`1 args, String baseDirectory, String sdkDirectory, String additionalReferenceDirectories)
   at Microsoft.CodeAnalysis.CSharp.CSharpCommandLineParser.CommonParse(IEnumerable`1 args, String baseDirectory, String sdkDirectoryOpt, String additionalReferenceDirectories) 
   at Microsoft.CodeAnalysis.CommandLineParser.Parse(IEnumerable`1 args, String baseDirectory, String sdkDirectory, String additionalReferenceDirectories)
   at Microsoft.CodeAnalysis.CommonCompiler..ctor(CommandLineParser parser, String responseFile, String[] args, String clientDirectory, String baseDirectory, String sdkDirectoryOpt, String additionalReferenceDirectories, IAnalyzerAssemblyLoader analyzerLoader) 
   at Microsoft.CodeAnalysis.CSharp.CSharpCompiler..ctor(CSharpCommandLineParser parser, String responseFile, String[] args, String clientDirectory, String baseDirectory, String sdkDirectoryOpt, String additionalReferenceDirectories, IAnalyzerAssemblyLoader analyzerLoader) 
   at Microsoft.CodeAnalysis.CSharp.CommandLine.Csc..ctor(String responseFile, BuildPaths buildPaths, String[] args, IAnalyzerAssemblyLoader analyzerLoader) 
   at Microsoft.CodeAnalysis.CSharp.CommandLine.Csc.Run(String[] args, BuildPaths buildPaths, TextWriter textWriter, IAnalyzerAssemblyLoader analyzerLoader) 
   at Microsoft.CodeAnalysis.CommandLine.DesktopBuildClient.RunLocalCompilation(String[] arguments, BuildPaths buildPaths, TextWriter textWriter) 
   at Microsoft.CodeAnalysis.CommandLine.BuildClient.RunCompilation(IEnumerable`1 originalArguments, BuildPaths buildPaths, TextWriter textWriter) 
   at Microsoft.CodeAnalysis.CommandLine.DesktopBuildClient.Run(IEnumerable`1 arguments, IEnumerable`1 extraArguments, RequestLanguage language, CompileFunc compileFunc, IAnalyzerAssemblyLoader analyzerAssemblyLoader) 
   at Microsoft.CodeAnalysis.CSharp.CommandLine.Program.Main(String[] args, String[] extraArgs) 
   at Microsoft.CodeAnalysis.CSharp.CommandLine.Program.Main(String[] args)
C:\Program Files (x86)\MSBuild\14.0\bin\Microsoft.CSharp.Core.targets(67,5): error MSB6006: "csc.exe" exited with code 255.
```
 
A NullReferenceException is occurring inside a call to CompilationOptions.Errors:
 
``` csharp
public ImmutableArray<Diagnostic> Errors
{
    get { return _lazyErrors.Value; }
}
```
 
The only possible source of null here is the field _lazyErrors yet it is readonly and assigned unconditionally in the only constructor of the type.  It should never be null.  This code in in the initial startup path of csc so there aren’t any whacky multi-threading issues that need to be considered.  It’s simple, straight forward code that should never have a NullReferenceException.   It’s an impossible bug yet the customer can reliably reproduce the crash.
 
In cases like this one possibility to consider is the impact of profilers on a .NET process.  The [CLR APIs](https://msdn.microsoft.com/en-us/library/ms232096(v=vs.110).aspx) allows profilers to modify the IL of method bodies.  This is typically done in order to record events such as allocations, method entry, method exit, etc …  Profilers though are just code and themselves can have bugs.  This includes generating incorrect IL that can open the door to crashes like this.

Checking for the impact of profilers is straight forward when a crash dump is available.  For this particular dump you would take the following steps in WinDbg:
 
```
!name2ee Microsoft_CodeAnalysis!Microsoft.CodeAnalysis.CompilationOptions.get_Errors
```
 
This will dump out a lot of runtime information about the JIT’d method.  The value of interest though is the MethodDesc field.  In this case it was 000007fe986d9948.  This value lets us look at the generated assembly for the method:
 
```
!U 000007fe986d9948
```

This will dump out the following assembly.
 
```
000007fe`988f9043 e8989bb1ff      call    Typemock.Interceptors.Profiler.InternalMockManager.getReturn(System.Object, System.String, System.String, System.Object, Boolean, Boolean) (000007fe`98412be0)
000007fe`988f9048 488945d8        mov     qword ptr [rbp-28h],rax
000007fe`988f904c 49b8e833048005000000 mov r8,5800433E8h
000007fe`988f9056 4d8b00          mov     r8,qword ptr [r8]
000007fe`988f9059 48baf02f048005000000 mov rdx,580042FF0h
000007fe`988f9063 488b12          mov     rdx,qword ptr [rdx]
000007fe`988f9066 488b4d10        mov     rcx,qword ptr [rbp+10h]
000007fe`988f906a 4533c9          xor     r9d,r9d
000007fe`988f906d e8469bb1ff      call    Typemock.Interceptors.Profiler.InternalMockManager.ClearRefParameter(System.Object, System.String, System.String, Boolean) (000007fe`98412bb8)
000007fe`988f9072 488b55d8        mov     rdx,qword ptr [rbp-28h]
000007fe`988f9076 488955d0        mov     qword ptr [rbp-30h],rdx
000007fe`988f907a 488b55d8        mov     rdx,qword ptr [rbp-28h]
000007fe`988f907e 4885d2          test    rdx,rdx
```

It’s not really necessary to fully understand the assembly to diagnose the profiler here.  I certainly don’t have the necessary depth with assembly to do so.  But one particular item of interest is the call instruction.

The target of the call is the namespace `TypeMock.Interceptors.Profiler`.  That is certainly not a component of the Roslyn code base.  Yet it is clearly referenced in the generated assembly.  That confirms pretty strongly that a profiler is being used in this scenario to modify the IL in the assembly.  Given all the other data it’s pretty reasonable to assume the modified IL is the source of the NullReferenceException.  

Cases like this though are pretty rare.  I typically investigate around 20 crash reports a month and see this happen less than once a year.  

---
layout: post
title: string vs. String is not a style debate
tags: [c#, style]
---
One thing that frustrates me ***

The keyword `string` has concrete meaning in C#. It is the type `System.String` which exists in the core runtime 
assembly. If that type doesn't exist the compiler will exit before attempting to even parse a line of code. Hence 
`string` has a precise, unambiguous meaning in C# code.

The identifier `String` though has no concrete meaning in C#. It is an identifier that goes through all the name 
lookup rules as `Widget`, `Student`, etc ... It could bind to `string` or it could bind to a type in another assembly
entirely whose purposes may be entirely differnt than `string`. Worse it could be defined in a way such that code 
like `String s = "hello";` continued to compile. 

The actual meaning of `String` will depend on name resolution. That means it depends on all the source files in the 
project and all the types defined in all the referenced assemblies. In short it requires quite a bit of context to 
*know* what it means. 

True that in the vast majority of cases `String` and `string` will bind to the same type. But using `String` still 
means developers are leaving their program up to interpretation in places where there is only one correct answer. When
`String` does bind to the wrong type it can leave developers debugging for hours, filing bugs on the compiler team
and generally wasting time that could've been saved by using `string`. 

One way to visualize the difference is with this sample:

``` csharp
string s1 = 42; // Errors 100% of the time 
String s2 = 42; // Might error, might not, depends on the code
```

Many will argue that while this is technically accurate `String` is still fine because it's exceedingly rare that a
code base would define a type of this name. Or that when `String` is defined it's a sign of a bad code base.

The reality though is quite different. Defining `String` happens with some regularity as is demonstrated by the 
following [BigQuery](https://console.cloud.google.com/bigquery?sq=184227942691:b210a08dadec4efdb07eb6ff982893ae): 

``` sql
SELECT  
  sample_path, sample_repo_name
FROM `fh-bigquery.github_extracts.contents_net_cs`
WHERE 
  NOT STRPOS(sample_repo_name, 'coreclr') > 0
  AND NOT STRPOS(sample_repo_name, 'corefx') > 0
  AND NOT STRPOS(sample_repo_name, 'roslyn') > 0
  AND NOT STRPOS(sample_repo_name, 'corert') > 0
  AND NOT STRPOS(sample_repo_name, 'mono') > 0
  AND STRPOS(content, 'class String ') > 0
LIMIT 100
```

Looking through these results you'll see that `String` is defined for a number of completely valid purposes: 
reflection helpers, serialization libraries, lexers, protocols, etc ... For any of these libraries `String` vs.
`string` has real consequences depending on where the code is used.

This discussion is not limited to `string`. It also applies to `object`, `int`, `long`, etc ... 

The take away here is that 
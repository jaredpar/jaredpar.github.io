---
layout: post
---
Recently I made a very large update to our code base. Our code base lacked a standard way of guarding entry and exit points into the various components.  Having said guards is useful for error handling, tracing, reducing redundancy, etc ... The edit standardized our entry points by adding start/end macros to our entry point functions. In addition to other house keeping, the macros also created an HRESULT variable named "hr". Example below.

``` c++
    #define MY_ENTRY_GUARD() HRESULT hr
    #define MY_ENTRY_EXIT() return hr
```

Ran suites, everything passed, checked in. Then I got an email from another dev who spent some time tracking down a bug related to this check-in (sorry [Calvin](http://blogs.msdn.com/calvin_hsia/)). He discovered one scenario my fix did not take into account.

``` c++
SomeMethod
{
  MY_ENTRY_GUARD();
  if ( somecondition ) {
    HRESULT hr = E_FAIL; // shadows the first hr
  }
  MY_ENTRY_EXIT(); // returns unmodified hr
}
```

The double declaration of the variable "hr" is not an error or even a warning in C++. Instead the inner "hr" shadows the outer and hence the rest of the method doesn't update the "hr" which is actually returned. So now I had to find every place in this change where a nested hr was declared. Did I mention this edit was huge' Going through by hand would not only be time consuming, it would also be very error prone.

At first I considered parsing out the C++ and doing basic brace matching to look for shadowing "hr" variables. I ruled that out due to the amount of time I would need to invest in the script to take into account comments, string literals, etc ... Really I didn't need brace matching, I really just needed to know when I entered and left a method. Almost all C++ methods have their opening and closing braces on the first column. Writing a script to detect this is trivial.

Script took about 5 minutes to write and 10 to run in the code base. Saved me countless hours of error prone reviews. Thank you PowerShell.

Find-DoubleHr.ps1:

    param ( $argFileName = $(throw "Need a file name") )

    function Do-Work() {  
       $i = 0  
       foreach ( $line in (gc $argFileName) )   {  
           new-tuple "Text",$line,"LineNumber",$i  
           $i++  
       }  
    }

    function Do-Parse() {  
       begin {  
           $inMethod = $false  
           $seenHresult = 0  
           $seenMacro = 0  
       }  
       process {  
           $tuple = $_  
           if ( $inMethod ) {  
            switch -regex ($tuple.Text) {  
               "^}" {  
                   $inMethod = $false  
                   if ( ($seenHresult -ne 0 )-and ($seenMacro -ne 0) ) {  
                    "Found a double {0},{1}" -f $seenHResult,$seenMacro  
                   }  
                   $seenHresult = 0  
                   $seenMacro = 0  
                   break  
               }  
               ".*MY_ENTRY_GUARD.*" {  
                   write-debug ("Macro: {0} " -f $tuple.Text)  
                   $seenMacro = $tuple.LineNumber  
                   break  
               }  
               "HRESULT.*\Whr\W" {  
                   write-debug ("HResult: {0}" -f $tuple.Text)  
                   $seenHresult = $tuple.LineNumber  
                   break  
               }  
            }  
           }  
           elseif ( $tuple.Text -match "^{" ) {  
            $inMethod = $true  
           }  
       }  
    }

    "Processing $argFileName"  
    Do-Work | Do-Parse


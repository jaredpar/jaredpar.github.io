---
layout: post
---
Recently at work I started using Windows 2008 64 bit edition. Mainly for hyper-v but powershell also comes as part of the deal.

I'm starting to work through the fun issues of getting some of my environment specific scripts to run in a 64 bit powershell process. The following scripts are turning out to be fairly handy

``` powershell
# Is this a Wow64 powershell host
function Test-Wow64() {
    return (Test-Win32) -and (test-path env:\PROCESSOR_ARCHITEW6432)
}

# Is this a 64 bit process
function Test-Win64() {
    return [IntPtr]::size -eq 8
}

# Is this a 32 bit process
function Test-Win32() {
    return [IntPtr]::size -eq 4
}
```

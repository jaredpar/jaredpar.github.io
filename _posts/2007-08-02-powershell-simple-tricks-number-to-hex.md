---
layout: post
---
When investigating bugs a lot of times you start out with an unfamiliar
HRESULT value.  Searching the web will give you a hint of what the problem is
and the real search can begin.  If you get this error out of a log file it can
come in a base 10 value versus a base 16 (hex).  Searching for your base 10
code is much less efficient that the hex counter part.  No matter.



C:\Users\jaredpar> "0x{0:x}" -f -2147023293 | out-clipboard


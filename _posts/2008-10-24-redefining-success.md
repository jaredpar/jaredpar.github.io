---
layout: post
---
Spent about an hour debugging a bit of code today. I was attempting to read
data from a particular source and kept getting back failure codes. After some
debugging I discovered the data didn't actually exist in the source I was
reading from.

This put me back to investigating where I wrote the data out. Restarted the
scenario and verified that I actually called the data writing API and that it
succeeded.

Now what' Well the data clearly wasn't there so I concluded the data writing
must be failing in some odd way. I eventually found the data writing code and
was horrified to find the following definition.

    
    
    HRESULT WriteSomeData(...) {


      // We don't support data of this type


      return S_OK;


    }

Personally I thought this warranted an error code (perhaps E_NOTIMPL). But
given the situation I must conclude the author successfully failed to write
the data.


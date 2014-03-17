---
layout: post
---
Recently while making a bug fix to our selection tracking code I discovered an unexpected behavior with CComPtr<T> instances. The crux of the fix included creating a new tracking mechanism exposed via COM in the type ISelectionTracking. The old interface, lets call it IOldTracking, was a completely unrelated interface in terms of inheritance hierarchies.

As part of the fix I changed the type of a field (m_spTracking) from CComPtr<IOldTracking> to CComPtr<ISelectionTracking>. I searched for assignments of m_spTracking and converted them to call the new API I added as part of the fix. I didn't search terribly hard because I was depending on the compiler to catch any places I missed. ISelectionTracking and IOldTracking are incompatible types so any places I missed will show up as compilation errors.

Or so I thought 

I made my fix, ran our core check-in suites without error, checked in and moved onto the next bug. A couple hours later one of our other devs emailed me and informed me my check-in was breaking our larger, slower, suite bed run because m_spTracking was NULL. After some quick debugging I found myself looking at the following chunk of code which was apparently NULL'ing out m_spTracking in the suite.

{% highlight c++ %}
CComPtr<IOldTracking> spOldTracking;
if ( SUCCEEDED(CreateOldSelectionTracking(&spOldTracking)) ) {
m_spTracking = spOldTracking;
}
{% endhighlight %}

Me and the other dev were quite shocked that this compiled at all. How is it possible to assign between CComPtr<ISelectionTracking> and CComPtr<IOldTracking>'?? My first thought was I must have accidentally used a CComQIPtr somewhere (quickly verified that was not the case). After a bit of searching we found the cause was one of the operater=?? instances available on CComPtr<T>. Here is the definition

{% highlight c++ %}
template <typename Q>
T* operator=(_In_ const CComPtr<Q>& lp) throw()
{
    if( !IsEqualObject(lp) )
    {
        return static_cast<T*>(AtlComQIPtrAssign((IUnknown**)&p, lp, __uuidof(T)));
    }
    return *this;
}
{% endhighlight %}

This templated operator allows for assignments between CComPtr instance no matter what the type is for the left and right side. The effect is that instead of doing compile type C++ type conversion rules, it will instead rely on runtime COM polymorphic assignment rules via IUnknown::QueryInterface.  This moves assignment errors from compile time to runtime for unrelated interfaces.

This is further complicated because it only applies to assignment between CComPtr's (and derived instances). If the right hand side of the assignment is a non-smart pointer, compile time C++ conversions will apply. To demonstrate '

{% highlight c++ %}
CComPtr<ISelectionTracking> spTracking;
CComPtr<IOldTracking> spOld;
...
spTracking = spOld;  // Fails at runtime
spTracking = (IOldTracking*)spOld;  // Compilation Error
{% endhighlight %}


What surprised me though was talking to other developers about this issue.  Most agreed with me that this is a bug in CComPtr<T>, or at least very unexpected behavior. A surprising number though did not expect this behavior but still considered it acceptable. The difference comes down whether you view CComPtr<T> as a simple smart pointer responsible for AddRef/Release semantics or as that plus an enabler of QueryInterface style conversions. I personally view CComPtr<T> as a simple smart pointer with know real understanding of QueryInterface style conversions and CComQIPtr<T> as a smart pointer which respects QueryInterface style conversions.' As such this behavior is completely unexpected.

The fix in this case was pretty straight forward (use the new API) but I was still worried about how to prevent this type of problem in the future. In particular how to get the failure back to a compile time error. In the end we settled on using a stripped down version of CComPtr we already had in our code base going forward called CComPtrEx. I've previously blogged about about the need for this type [here]({% post_url 2008-02-22-multiple-paths-to-iunknown %}). It's different from CComPtr in the following ways

  * Does not have the templated version of operator= and instead relies on compile time C++ conversions checks for assignment 
  * Allows for interfaces which have multiple paths to IUnknown (can cause a compile time error in CComPtr). 

Also for purposes of rigor, we temporarily commented out the CComPtr<T> operator, recompiled our code base and verified no new errors popped up.


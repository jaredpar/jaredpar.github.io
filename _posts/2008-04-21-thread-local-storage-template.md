---
layout: post
---
Thread local storage is another method of synchronization between threads.  It is different that most synchronization cases because instead of sharing state between threads it enables developers to have independent, thread specific pieces of data which have a similar or common purpose.

The uses of thread local storage (TLS) vary greatly but is a very powerful and lightweight method for storing data.  TLS can easily be envisioned as a giant void* array for every thread.  The entry point, TlsAlloc, provides an index into this array and allows the storage of arbitrary data [1].  

TLS is particularly useful for storing state information.  For example, one of my components lives in a highly multi-threaded environment.  Each thread serves essentially the same purpose and has the same states and state transition semantics.  Like any good paranoid programmer I wanted to add contracts to check my state transitions and semantics.

> Contract.VerifyState(ExpectedState, 'CurrentState)

The question is where to store the state information for a thread?  A global state variable won't suffice because there are N threads.  A global array of state information also has it's share of problems: synchronization, determining an index, lifetime.

TLS is ideally suited to this scenario.  Each thread has an independent but similar concept of state.  In my initialization code I allocate an TLS index and now I have a place to store my state.

> Contract.VerifyState(ExpectedState, *TlsGetValue(g_stateTlsIndex)

The next question is how to manage the lifetime?  TLS provides a void* and the caller must manage the lifetime of the allocated memory.   Since this is thread specific the ideal place is to manage the memory in the thread startup proc.  However I don't own the creation of the thread, my component is called on a number of threads so this won't work.

The solution is to use the stack.  The initial return for TlsGetValue is NULL.  If this situation is detected then the current stack frame is set to own the memory for the slot.  Further accesses to the value do not own the memory and simply access it.  The semantics are straight forward but annoying to constantly rewrite, so naturally write a template :)

{% highlight c++ %}
template <typename T>
class TlsValue
{
public:
    TlsValue(DWORD index, const T& defaultValue=T()) :
        m_pValue(NULL),
        m_index(index),
        m_owns(false)
    {
        m_pValue = reinterpret_cast<T*>(::TlsGetValue(m_index));
        if ( !m_pValue )
        {
            m_pValue = new T(defaultValue);
            m_owns = true;
            ::TlsSetValue(m_index, m_pValue);
        }
    }
    ~TlsValue()
    {
        if ( m_owns )
        {
            ::TlsSetValue(m_index, NULL);
            delete m_pValue;
        }
    }

    T* Value() const
    {
        return m_pValue;
    }

private:
    // Do not auto generate
    TlsValue();
    TlsValue(const TlsValue<T>&);
    TlsValue& operator=(const TlsValue<T>&);

    T* m_pValue;
    DWORD m_index;
    bool m_owns;
};
{% endhighlight %}
    

In addition to this blog post, I added a working sample to <http://code.msdn.microsoft.com/TlsValue>.  This is my first attempt at posting a sample on <http://code.msdn.com> so please provide any and all feedback on the data.

[1] This is similar to data marked with the [ThreadStatic attribute](http://msdn2.microsoft.com/en-us/library/system.threadstaticattribute\(VS.71\).aspx) in managed code without all of the slot messiness and with the added benefit of strong typing.


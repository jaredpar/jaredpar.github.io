---
layout: post
---
[DebuggerNonUserCode](http://msdn2.microsoft.com/en-us/library/system.diagnostics.debuggernonusercodeattribute.aspx) is an attribute that tells the debugger that the target item is not code typed by the user.  It can be added to classes, structs, methods, constructors and properties.

The benefits of this attribute is that it allows the compiler and designers to distinguish user code from generated code.  As such the debugging experience can be altered.  When this attribute is present and "Just My Code" (JMC) is on the debugger will not step into or break in these methods for normal cases.  Instead it will treat it is if it was a call to a framework assembly.

However if you type code like the following you won't get the behavior you probably expect.

``` vbnet
Class C1
    Private m_f1 As Integer

    <DebuggerNonUserCode()> _
    Property P1() As Integer
        Get
            Return m_f1
        End Get
        Set(ByVal value)
            m_f1 = value
        End Set
    End Property
End Class
```

While investigating a recent bug I found that I could step into the get/set method of properties annotated with DebuggerNonUserCode.  The reason why is a bit unexpected.  The attribute is applied to the property, not the get/set method.  The debugger will only check the actual methods involved.  It doesn't special case properties in any fashion.  If you want to get the expected behavior, you have to annotate the get/set method directly.

``` vbnet
Class C1
    Private m_f1 As Integer

    Property P1() As Integer
        <DebuggerNonUserCode()> _
        Get
            Return m_f1
        End Get
        <DebuggerNonUserCode()> _
        Set(ByVal value As Integer)
            m_f1 = value
        End Set
    End Property
End Class
```

I'm not saying this is the best solution but it will work for both VS 2005 and VS 2008.  IMHO ideally this attribute when applied to a property would affect both the get and set method.  

---
layout: post
---
[Fortune](http://en.wikipedia.org/wiki/Fortune_\(program\)) is a Unix command that gets a random message from a set of databases and displays it on the screen. These messages have a wide variety but tend to be funny, quirky or famous quotes (most are indeed geeky).

Nearly all unix systems have a version of Fortune. Windows doesn't have any version by default. It provides no real functionality other than humor and amusement but it's something I miss. Most users add it to their .profile script so they get a new fortune every time they log in.

There are a couple of heavy weight options to get fortune on my machine?? but I prefer something a bit lighter. I did a quick search and discovered that [Doug Hughes](http://www.doughughes.net/index.cfm?event=fortune) implemented a fortune web service. This is just above as light weight as it gets so I implemented a simple PSCmdlet, get-fortune, to do the work (code below).

Now I can just add a quick get-fortune to my profile script.

    C:\Users\jaredp> get-fortune pets  

Does the name Pavlov ring a bell?
    
``` vbnet
<Cmdlet(VerbsCommon.Get, "Fortune")> _
Public Class GetFortune
    Inherits PSCmdlet

    Public Const TopicHelpMessage = "Restricts fortune output to the specified topic"

    Private m_topic As String = String.Empty
    Private m_minimumLength As Integer
    Private m_maximumLength As Integer
    Private m_timeout As Integer = 100000

    <Parameter( _
               Position:=0, _
               HelpMessage:=TopicHelpMessage, _
               ValueFromPipeline:=True, _
               ValueFromPipelineByPropertyName:=True)> _
    Public Property Topic() As String
        Get
            Return m_topic
        End Get
        Set(ByVal value As String)
            m_topic = value
        End Set
    End Property

    <Parameter(Position:=1)> _
    Public Property MinimumLength() As Integer
        Get
            Return m_minimumLength
        End Get
        Set(ByVal value As Integer)
            m_minimumLength = value
        End Set
    End Property

    <Parameter(Position:=2)> _
    Public Property MaximumLength() As Integer
        Get
            Return m_maximumLength
        End Get
        Set(ByVal value As Integer)
            m_maximumLength = value
        End Set
    End Property

    <Parameter(Position:=3)> _
    Public Property Timeout() As Integer
        Get
            Return m_timeout
        End Get
        Set(ByVal value As Integer)
            m_timeout = value
        End Set
    End Property

    Protected Overrides Sub ProcessRecord()
        Dim proxy As New DougHughes.fortune
        Dim topic = m_topic
        If topic Is Nothing Then
            topic = String.Empty
        End If

        proxy.Timeout = m_timeout
        WriteObject(proxy.getFortune(topic, m_minimumLength, m_maximumLength))
    End Sub

End Class
```


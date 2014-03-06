---
layout: post
---
The WinForms [Timer](http://msdn.microsoft.com/en-us/library/system.windows.forms.timer.aspx) class allows the user to perform a particular action at a set interval. Timer objects fire a [Tick](http://msdn.microsoft.com/en-us/library/system.windows.forms.timer.tick.aspx) event at the set time which users can easily respond to. This is very useful if a developer wants to check for a particular condition say every 2 seconds ( for the remainder of this article I'm going to use 2 seconds as a practical example even though it's really any arbitrary time period).

Occasionally users are surprised to find that the Tick event will fire much faster than they are expecting. Instead of waiting for 2 seconds between calls, they event will fire almost immediately after one is finished processing.

What's going on here is a side effect of how this event works under the hood.  The interval for the timer event is calculated in real world time. So quite literally every 2 seconds Windows will consider the internal reached and will issue a new tick message. The next time a WinForms event is not executing developer code a tick event is raised [1].

So imagine we had the following code.

{% highlight vbnet %}
Private Sub OnTimerTick() Handles m_timer.Tick
    RunSomeOperation()
End Sub
{% endhighlight %}

Consider what happens if RunSomeOperation takes longer than 2 seconds. The Tick event is fired in real time so while we're in the middle of RunSomeOperation, another Tick event is being queued up for processing. As soon as we leave OnTimerTick we're back in WinForms code which sees a Tick event and promptly raises it which puts us right back in OnTimerTick.  

This is contrary to what most people expect. Most people expect the Tick event to fire 2 seconds after their code is finished executing.

To work around this developers should stop the timer when processing a timer event. Just before exiting the event handler, re-enable the timer. This will cause Windows to start calculating the interval from the start. This has the effect of making the timer event fire 2 seconds after developer code stops executing.

{% highlight vbnet %}
    Private Sub OnTimerTick() Handles m_timer.Tick
        m_timer.Stop()
        Try
            RunSomeOperation()
        Finally
            m_timer.Start()
        End Try
    End Sub
{% endhighlight %}

[1] This is not 100% true. It's really whenever the Application begins to pump messages again. Message pumping, more specifically when it does and does not occur, is too involved for this discussion.  

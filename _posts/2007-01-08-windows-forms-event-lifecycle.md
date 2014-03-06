---
layout: post
---
When deveploping windows forms app, it's important to understand the event lifecycle of a form.  That way you know what code to put where to ensure it's loaded at the appropriate time.  That being said I wrote a small app to detail the events in a basic windows form application.  Greater indentations indicate nested events

Form Startup

1. OnHandleCreated
2. OnCreateControl
    1. OnLoad
3. OnActivated
4. OnShown

Form Shutdown

1. OnClosing
2. OnClosed
3. OnDeactivate
4. OnHandleDestroyed


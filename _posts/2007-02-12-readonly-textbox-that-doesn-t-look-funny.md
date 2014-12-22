---
layout: post
---
When you make a WinForm TextBox ReadOnly, it aquires a distinctive look because it changes the background.  Users often want the appearance of the TextBox to stay the same, they just don't want it to be mutable.  Here's a snippet to make a TextBox ReadOnly and not change it's appearance.

``` vbnet
Dim saved As Color = Me.TextBox1.BackColor
Me.TextBox1.ReadOnly = True
Me.TextBox1.BackColor = saved
```


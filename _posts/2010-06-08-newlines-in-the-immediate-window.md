---
layout: post
---
A [question](http://stackoverflow.com/questions/2868862/newlines-in-the-
immediate-window) came up recently on stack overflow concerning the display of
newlines in the immediate window.'? The author noted that any .ToString method
which contained a newline printed incorrectly when evaluated in the immediate
window. For example given the following ToString implementation

    
    
    public override string ToString() {


        return "Hello" + Environment.NewLine + "World";


    }

The immediate window would display the following. Noticed how the newline was
printed as the actual escape sequence instead of a physical newline.

![image](http://blogs.msdn.com/cfs-file.ashx/__key/CommunityServer-Blogs-
Components-WeblogFiles/00-00-00-39-97-metablogapi/1754.image5_5F00_thumb_5F00_
3FF3114E.png)

This behavior is not limited to ToString calls but will occur for any place an
expression evaluates to a raw string.'? This behavior in the immediate window
case is a fallout from the architecture of the debugger components.

The current level of fidelity in the debugger APIs prevent the expression
evaluator from knowing which window it is providing data for. It is simply
asked to evaluate expressions and provide data with very little in the way of
context. In some ways this is a good thing because it trims down the number
of scenarios to test because it limits the number of ways it is produced. The
downside of course is that data provided must be able to work in every window
and hence a bit more generic. Often times this leads to trade offs in how
data is formatted.

Newlines are one of the places where a trade off was made. The immediate
window is unique in that it's the only window in the debugger where the
default display contains multiple lines. Every other window (watch, locals,
autos, etc ') contains a single line for display. Attempting to display a
multiline string in a single line results in either having only the first or
last line be visible. Hence the expression evaluators chose to escape the
newlines to make more of the string visible in the majority scenario [1]

In the case this happens there is a built-in debugger visualizer which allows
for the string to be displayed without any escaping. Simple click on the
magnifying glass and select the Text Visualizer option. This pops up a modal
dialog displaying the string in an unaltered form

??![image](http://blogs.msdn.com/cfs-file.ashx/__key/CommunityServer-Blogs-
Components-WeblogFiles/00-00-00-39-97-metablogapi/4745.image_5F00_thumb_5F00_2
5B2A82A.png)

![image](http://blogs.msdn.com/cfs-file.ashx/__key/CommunityServer-Blogs-
Components-WeblogFiles/00-00-00-39-97-metablogapi/4747.image_5F00_thumb_5F00_2
10C77A3.png)

[1] This escaping does not always happen. Essentially only when the data is
specifically typed to a System.String


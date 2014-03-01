---
layout: post
---
One item you strive to avoid when you design and implement a feature is
unexpected behavior. Unfortunately there is one case we couldn't avoid with
Lambda's in VB9. I just ran into the this problem when coding up a handler.
I wanted to disable a button when the text of particular TextBox was empty. I
wrote the following code to handle the situation.

    
    
    AddHandler c.TextChanged, Function() okButton.Enabled = (0 <> c.Text.Length)

This doesn't quite do what I intended. This instead will simply compare the
two values.

In VB9 Lambda Expressions are always an expression. In version 9 of VB, there
is no concept of an assignment as an expression. There is only a statement
version. As a result this doesn't do anything useful.

This has tripped up a few people along the way. It's an unfortunate side
effect of only supporting expression lambdas.

I was able to work around this by defining a function which did what I
intended. I called this function in the lambda expression and the problem was
solved.


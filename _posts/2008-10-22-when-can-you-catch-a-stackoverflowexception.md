---
layout: post
tags: [clr, gotcha]
---
Answer: When you're the one who threw it.

Starting with the CLR version 2.0, the policy for handling a [StackOverflowException](http://msdn.microsoft.com/en-us/library/system.stackoverflowexception.aspx) was changed. User code can no longer handle the exception[^1]. Instead the CLR will simply terminate the process.

This is not 100% true though. User code can still handle StackOverflowExceptions which are artificially thrown. That is thrown by the user instead of resulting from an actual overflow of the stack. This is in contradiction to the documentation but can be demonstrated with a quick and dirty sample program (see end of the post).

This is a trivial point for sure. Yet I feel the need to point it out because I recently saw a newsgroup conversation where someone posted sample exception logging code and happened to use a StackOverflowException in the sample.  Their sample explicitly threw the exception so it worked and they had good reason to suspect it worked in production as well. I was equally amazed it worked at all.

Please don't take this post as advocating that you should handle a StackOverflowException (you shouldn't). This is merely an oddity I found interesting. Personally I'd prefer it not be catch-able in any circumstance.

``` csharp
public static void CatchStackOverflow1() {
    try {
        throw new StackOverflowException();
    } catch (StackOverflowException ex) {
        // Executes and handles the exception.  User code continues
        Console.WriteLine(ex.Message);
    }
}

static int CreateRealOverflow(int p1) {
    return 42 + CreateRealOverflow(p1 + 1);
}

public static void CatchStackOverflow2() {
    try {
        CreateRealOverflow(42);
    } catch (StackOverflowException ex) {
        // Will not execute
        Console.WriteLine(ex.Message);
    }
}

static void Main(string[] args) {
    CatchStackOverflow1();
    CatchStackOverflow2();
}
```

[^1]: Unless you are hosting the CLR in which case you can implement some recovery mechanism. This is certainly the exception though and not the rule. 



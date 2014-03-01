---
layout: post
title: Don't mix await and compound assignment
---
The 5.0 release of C# introduced the await keyword which makes it extremely
easy to use Task<T> in a non-blocking fashion. This allows developers to
replace either blocking calls to Task.Wait() or complicated combinations of
ContinueWith and callbacks with a nice simple, straight forward expression

{% highlight csharp %}
Task<int> task = ...;
int local = await task;
Use(local);
{% endhighlight %}

What most people don't consider is the implications of this non-blocking
support. At the point the 'await task' expression executes the program can do
one of two things. If task is resolved the await expression will complete and
the method will continue executing immediately. If it's not then the method
will pause and some other part of the program will wake up and start running.
This other code interleaves with with the execution of this method. This
means subtle timing changes in when Task values are resolved can drastically
alter the order in which a program executes.

These method interleavings can be the source of many subtle bugs in the
program. They are typically timing related and hence often don't predictably
reproduce and possibly don't show up at all until the program is executing on
a customers machine. One of the most common bugs I see is when developers
mistakenly combine compound assignment with the await keyword

{% highlight csharp %}
x += await y;
{% endhighlight %}

The C# compiler will rewrite this code into roughly the following [1]

{% highlight csharp %}
x = x + await y;
{% endhighlight %}

And it executes in the following steps

  1. load x onto the stack 
  2. await y 
  3. Push result of 'await y' onto the stack 
  4. Add the stack values 
  5. Store into x

In the case where 'y' isn't resolved the execution of this code will stop at
step #2. At which point some other code will begin executing in its place.
If 'x' is a local there isn't much danger here but what if 'x' represents a
field that is accessible to another part of the program' And what if that
field is modified while this expression is paused at #2' When this statement
resumes it will never re-read the value of 'x' and hence any writes to it
which occurred during the pause will be erased once the expression completes.
Or in other words, it will quite simply ignore the other write.

I most frequently see this problem with accumulator scenarios. A collection
of tasks are spun up and the results are tallied up as they complete

{% highlight csharp %}
class Accumulator
{
    private int m_sum;

    public int Sum
    {
        get { return m_sum; }
    }

    public async Task Add(Task<int> value)
    {
        m_sum += await value;
    }
}
{% endhighlight %}

This code is fundamentally incorrect because it invites this very problem.
Consider the following scenario

  1. Call to Add is made with an unresolved Task. Add pauses on the task having already read m_sum onto the stack
  2. Call to Add is made with a resolved Task with a value of 4. Add completes and m_sum is now 4 
  3. Task from step 1 resolves with a value of 2. The value on the stack for m_sum is still 0 so m_sum is written out as 2 instead of 6 

The way to avoid this problem is to simply not mix await and the compound
operator. Instead store the await value into a temp and then do the
assignment without the risk of interleavings.

{% highlight csharp %}
public async Task Add(Task<int> value)
{
    var temp = await value;
    m_sum += temp;
}
{% endhighlight %}


Here is a sample which will demonstrate the bug in a deterministic fashion.

    
{% highlight csharp %}
var accumulator = new Accumulator();
var taskCompletionSource1 = new TaskCompletionSource<int>();
var taskCompletionSource2 = new TaskCompletionSource<int>();

var task1 = accumulator.Add(taskCompletionSource1.Task);
var task2 = accumulator.Add(taskCompletionSource2.Task);
taskCompletionSource2.SetResult(3);
taskCompletionSource1.SetResult(2);

await task1;
await task2;
Console.WriteLine(accumulator.Sum);
{% endhighlight %}

This code will print out 2 instead of the expected 5

[1] I use 'roughly' here because it the compiler actually does a more
complicated rewrite. It ensures that the side effects of 'x' happen exactly
once during the execution of this method. For locals though this is roughly
the code that is generated and serves fine for this example


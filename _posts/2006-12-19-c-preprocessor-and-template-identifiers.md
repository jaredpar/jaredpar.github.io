---
layout: post
---
A couple of hours of tracking down a compiler error a couple of days ago taught me something about the preprocessor I'd like to pass on so others can avoid the ... learning :).

I kept getting confronted by "constant expression must be followed by a ,".  Not the exact error but in the right range. This was a bit annoying because the error occurred on a simple template. Something along the lines of the following

{% highlight c++ %}
template<typename T1, typename T2> 
struct Foo
{
  ...
}
{% endhighlight %}

The long and short of it is the C/C++ processor will replace any word in a file if there is a corresponding macro with the same name.  This I knew from years of programming.  Every now and again you learn something new though.  The preprocessor will also try and expand template identifier's.  Normally this isn't a problem if the macro is just defined to another simple value.  For example, the below _usually_ won't cause you a headache

{% highlight c++ %}
#define KEY KEY2

template <class KEY>
class Pair
{
  ...
};
{% endhighlight %}

However if you try something fancy like the following, bad things start to happen
    
{% highlight c++ %}
#define KEY (KEY+2)
{% endhighlight %}

T1 was not the actual template identifier but it was a rather obscure word.  Some other header file being include was defining it to some complex macro. At the end of the day, I switched the template definition header file to be included first and to thus avoid the macro problem. I also added a few #define/#error combinations so that an error would occur if they were included in the wrong order


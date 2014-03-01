---
layout: post
---
The [last post](http://blogs.msdn.com/jaredpar/archive/2008/02/12/building-
the-base-future.aspx) dealt with building the base Future class. Now we'll
build the child class used to run [Func<TResult>](http://msdn2.microsoft.com
/en-us/library/bb534960.aspx)'s.

The basic implementation is straight forward. The class will run a delegate
typed to [Func<TResult>](http://msdn2.microsoft.com/en-
us/library/bb534960.aspx) in the override of RunCore. The trickiest part is
how to store the value. The value is set on one thread and read off of
another.

When a value is read and written on multiple threads there are a couple of
options for synchronization between threads. One of them is to use the
volatile keyword for the data. This forces the CLR to read the value from
memory every time and prevents caching issues between threads. Unfortunately
volatile cannot be applied to an unbounded generic.

To get around this I've declared the value to be of type object. Whenever the
value is accessed by the user of Future<T> a cast is applied to the
appropriate type. This incurs boxing overhead but it's minimal and in the
typical case will be limited to one box and unbox per value type.

In addition Future<T> adds one new method; Wait;?? It's a combination of
calling WaitEmpty followed by returning the value.

In a perfect world WaitEmpty in Future would really be called Wait and be
virtual. Future<T> would override the method and alter the return type to be
T. Unfortunately C#/VB don't support covariant return types on virtual method
overrides so it's not possible. Truthfully I don't know if this is a C#/VB
limitation or a CLR one.

    
    
        public class Future<T> : Future


        {


            private Func<T> m_function;


            private volatile object m_value;


    


            public T Value


            {


                get { return Wait(); }


            }


    


            public Future(Func<T> function)


            {


                m_function = function;


            }


    


            public T Wait()


            {


                base.WaitEmpty();


                return (T)m_value;


            }


    


            protected override void RunCore()


            {


                m_value = m_function();


            }


    


        }

Next time I'll go over the implementation of Futures which return no values.


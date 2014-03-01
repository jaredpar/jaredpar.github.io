---
layout: post
---
In addition to [Future<T>](http://blogs.msdn.com/jaredpar/archive/2008/02/13
/building-future-t.aspx) there is also the concept of Futures that don't
return any values. Instead the perform the operation and return. Because
there is no additional data to pass between the threads building an Empty
Future is fairly straight forward.

The biggest decision is how to declare it. EmptyFuture exposes no new
accessible methods or properties above what
[Future](http://blogs.msdn.com/jaredpar/archive/2008/02/12/building-the-base-
future.aspx) already exposes. If a class doesn't provide any additional
behavior is there any reason to expose it' In this case I think not.
Therefore it will be declared as a private inner class of
[Future](http://blogs.msdn.com/jaredpar/archive/2008/02/12/building-the-base-
future.aspx).

Yes this makes it impossible to directly create from a user perspective. You
could also make a good argument that creation is new behavior and therefore
EmptyFuture should be exposed. However for Future's, as with other generic
classes, I prefer static factory methods for creation. It allows the user to
take advantage of type inference as much as possible.

    
    
            private class EmptyFuture : Future


            {


                private Action m_action;


    


                internal EmptyFuture(Action action)


                {


                    m_action = action;


                }


    


                protected override void RunCore()


                {


                    m_action();


                }


    


            }

Next we'll go over the creation of the factory methods to create this and
Future<T>.


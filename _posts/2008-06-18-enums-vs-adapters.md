---
layout: post
---
I like Enums and use them frequently for options and behavior. To an extent I
use Enum's to control behavior. For example

    
    
    enum Kind {


        Kind1,


        Kind2,


        Kind3


    }


    


    class Example {


        private Kind m_kind;


    


        public int SomeAction() {


            switch (m_kind1) {


                case Kind.Kind1:


                    return ActionForKind1();


                case Kind.Kind2:


                    return ActionForKind2();


                case Kind.Kind3:


                    return ActionForKind3();


                default:


                    throw new InvalidOperationException("Invalid Kind");


            }


        }


    }

This is an acceptable pattern and use for enums. However if you take a step
back, what I've actually done here is use an enum to implement an [adapter
pattern](http://en.wikipedia.org/wiki/Adapter_pattern). I've just been a bit
lazy about it and not actually coded up the classes.

To an extent though this violates the principle of single use as Example now
performs N different behaviors based upon the enum. But lets face it, if
ActionForKindN() is just a simple 2 line function then is it really worth it
to create and maintain an adapter pattern' A purest would likely say yes but
I'm more pragmatic and don't believe so.

Once the functions reach a certain level of complexity though an adapter
pattern is much more suitable. Over time I find that many of my similar
patterns evolve to level.

Yet I struggle to define the point at which an adapter is suitable. After
several recent experiences I started adapting the following rules. If any of
them is violated then I switch from an enum based behavior to adapter based
behavior.

  1. The Action* method contains state
  2. There are more than 2 functions which change their behavior based on the enum value
  3. All methods in the class change their behavior based on the enum 

Anyone have a better set?


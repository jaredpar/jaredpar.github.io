---
layout: post
---
Title pretty much says it all but what good is a rule without any explanation.
The main issue here is that at the core, using statements and lambda
expressions both alter variable lifetimes.  Unfortunately they alter the
lifetime in different directions.  Using will shorten the life time of a
variable to the specified block.  This is a somewhat artificial way because
the object is still technically alive but can't be trusted to do anything.
Lambda expressions take a variable limited to a specific scope and extends
their lifetime to potentially be that of a heap value. Anytime two features
alter the attribute of a variable in different directions, they can probably
cause problems when used in conjunction.

Take the following contrived but real example.

    
    
            static Future<int> Example() {


                using (var obj = new MyDisosableObject()) {


                    return Future.Create(() => obj.SomeFunction());


                }


            }


---
layout: post
---
Some readers may remember an [article]({% post_url 2009-08-26-why-no-linq-in-debugger-windows %}) I published almost half a year ago about LINQ being absent from the debugger windows. That post explored the initial design of the feature, it's limitations and ultimately why it was absent but promised a future article on a slightly different approach. It's quite late but I've finally had some time to write the second part of this article [^1]

No, I didn't forget about the article or really get too lazy. The pace of Dev10 really picked up shortly after publishing that article and the follow up was put on the back burner. This week I finally find myself with a bit of free time and decided to follow up on my promise.

First a quick refresher. Features in the Expression Evaluator are started on the basis of having complete parity with the feature as it exists in the language and then paired down based on cost. Having complete parity with LINQ is prohibitably costly due to it being much more of an ENC expression instead of an inspection one (the latter being the primary purpose of an expression evaluator). Now comes the compromise phase.

As stated in the previous article the most expensive portion of this design is adding ENC support to the Expression Evaluator. ENC is necessary for true parity because closures in C# and VB.Net are mutable and requiring altering program state to implement. The standard example is evaluating the following expression in the EE which modifies the value of a local variable.
    
``` csharp
((Action)(() => { local1 = 42; }))();
```

Properly implementing this requires program mutation not just inspection.

Now comes the compromise. How often do users really want to do this' In my observations the answer is rarely if ever. When I talk with customers about LINQ in the debugger windows almost every single answer comes down to allowing filtering / where expressions. These are inherently, but not strictly, non- mutating operations.

    
``` csharp
list.Where(x => x.Name == "Jared");
```

Cutting mutation is a huge advantage because we can forget about the impact into existing closures and alteration of program structure. Instead we can generate new closures which copy the initial state of the values and work from there. This removes all of the state tracking problems examined in the previous article.

If we cut mutation, and hence ENC, we can move to a different approach for generating code. Instead of generating all of the types and methods in the current assembly with ENC, create a generated assembly in the target process which contains the new types and methods. This can be done through existing technologies like Reflection.Emit.

So How does that change the cost of the feature' If we look at the major feature list discussed in the previous article we'd only be left with the following

  1. A metadata generation service to support the backing for closures and lambda expressions 
  2. Converting expressions typed in the EE to IL 

Lets take a deeper look at this given our new proposed architecture.

**Metadata Generation Service**

The debugger and expression evaluator live in a different process than the debugee. Any generated lambda expression needs to be done in the debugee process. Yet all of the information needed to create the lambda exists in the debugger process. Implementing this feature requires that all of this data to be transferred between the processes. In effect we'd have to serialize both the metadata and IL of the trees and send them across the process boundary.

Creating a DLL to host the service, defining the interfaces and calling them from the EE all have costs. Yet many of these are done on every release and the cost is very much understood. Due to the regularity with which we do this we can cost this part with high confidence.

What's expensive here is defining the format for the data transfer. Today we don't directly generate IL in our compilers but instead use services exposed by the CLR to do so. We would need to define a new serialization format for transferring our representation of trees to the debugee process, deserializing this in the debugee and converting it to metadata and IL. This is actually very costly when you consider all of the details 

  * Needs to work in both a 32 and 64 bit environment 
  * The sheer amount of data as the number of nodes in our trees is quite large 
  * Data is transferred from a native process to a managed one so the structure for serializing data gets defined twice 
  * Versioning: 
    * This service must support both the current and new versions of the EE 
    * The serialization format must be able to handle the changes we make to our nodes over the course of several releases 
  * Performance 

Of all of these 'versioning' is the biggest cost. All to often we don't consider versioning when designing EE features and it comes back to haunt us in the long term.'? To implement such a large feature and not consider the versioning aspects would be a huge mistake.

The lack of previous work in this area and the overall size produces a feature with a high cost which has low confidence. Not what a manager wants to hear.  

**Converting Expressions in the EE to IL**

The expression evaluator does not actually compile expressions down into IL.  Instead it compiles it down to a low level semantic tree which is then directly interpreted by the expression evaluator.  

This approach grants a lot of flexibility to the EE and allows us to evaluate expressions that are not necessarily valid at the current place in the program. For example the ability to directly evaluate object id expressions.  This flexibility hurts us here because it creates a subset of expressions which are not, or at least very difficult to, translate to IL. How would an object id expression for instance be expressed in IL?  

The problem is not just limited to object id expressions but also include a host of other items allowed in the EE. There are too many to list in this article but suffice it to say this is not a trivial problem to solve [^2]. Any cost for this area would have at best a medium level of confidence.

The next problem with this approach is that our infrastructure which generates IL is heavily geared towards doing so for EXEs and DLLs. It has been so for every release of our code base and contains a lot of code very specific to this process. Converting this to be more general purpose is very costly at this point. It would entail almost a complete rewrite of those components.

Once again this cost in itself is not prohibitive but does add up. Really it amounts to a known type of refactoring with medium to high confidence.

**Wait there's more: Don't forget testing**

There are two costs to consider for the testing of this new feature. The first is the straight forward costs you get with any new features. This is a pretty standard and well understood process. The language side of the feature is not too difficult to test. The cost really starts adding up though when you consider all of the other parts which can go wrong: loading DLL's into the process, 32 / 64 bit issues, making sure all instructions serialize, versioning, etc '

The second more hidden cost though is the impact of this new feature on existing ones. Consider again that today all expressions typed into the EE are interpreted. However with our current design if the expression was inside of a lambda expression it would be executed not interpreted. This is a completely different process and would require a completely different set of tests to verify it's functionality.

In effect this would double the cost for QA for all existing features as they'd need to be tested inside a lambda expression. This is an enormous cost and one that cannot be ignored.

**In summary**

Here is a summary of the larger cost items

  1. Define a version friendly serialization format for transferring metadata and IL across the native and managed boundaries 
  2. Implement both the native serializer and managed deserializer for this format 
  3. Implementing a metadata generation service 
  4. All of the work around getting this DLL into the target process 
  5. Finding solutions for generating IL for all expressions which don't directly map to IL 
  6. Refactoring our existing compiler infrastructure to be friendly to generating IL for the EE 
  7. QA costs for testing this feature 
  8. QA work to double test every type of expression (inside and outside of a lambda) 

This doesn't take into account a lot of the smaller items I've ignored [^3] or the items we'd only find once we started implementing. This is after all a very large feature and those always have hidden costs that aren't found until implementation hits a certain point.

I'm very hesitant to put a strict time estimate on this feature (it would almost certainly be wrong given the hidden costs and the lack of confidence in estimating several areas). To put it in a bit of context though, I would estimate it as large and likely larger than any other feature I've worked on since I joined Microsoft.

Once again I'm not writing this blog post to justify why we won't ever implement LINQ debugging. Instead I write this to justify why we haven't done it up till this point. This is a feature which has clear customer value and a fair bit of demand and I want to help customers understand our decision making process in this area.

I'm still very hopeful this feature will make it into the product at a future release. Perhaps we'll find a cheaper route we're not currently considering.  Or maybe a future feature we need will offset some of the costs here.  

[^1]: This gap is certainly a personal record and one I hope to never beat

[^2]: One day I may write about these items because pretty much all exist to support a richer user experience.

[^3]: Anonymous types, transparent identifiers and VB generated delegates for starters


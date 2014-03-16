---
layout: post
---
As the owner of the VB.Net portion of the overall debugging experience, I frequently hear the request from customers to add LINQ support into the Watch / Immediate and Locals window.  Virtually every other type of expression is available in the debugger windows so why leave one of the most popular ones out?

Quick Diversion: the specifics of this article are written from the point of view of the VB.Net expression evaluator.  However, the limitations blocking LINQ support (in both the architecture and overall design) are very similar between VB.Net and C#.

As usual, the primary issue is cost and the cost for LINQ in the debugger windows is very high.  To understand why the cost is so high though, we must start by getting a better understanding how a language service interacts with the debugging services of Visual Studio and the general philosophy around compiler features in the debugger.

Languages in Visual Studio typically provide the following major components to support the debugging experience.

  * Expression Evaluator (EE): This is the language specific component which provides all of the data used in the watch, locals and immediate window, data tips, conditional breakpoints and several other components.  It's primary input is an expression in string form which is converted to a value (typically an ICorDebugValue instance) and outputs a COM object capable of inspecting that value to the core debugger [^1].   Everything typed into the debugger windows goes through the EE.

This component lives in the MTA of Visual Studio and has almost no interaction with the UI / STA thread.

  * ENC Service: This is the component which is the work horse of ENC operations.  It provides rude edit detection, metadata differencing and metadata + IL generation   .

This component lives in the main STA of Visual Studio

The important thing to understand about the expression evaluator is that it's purpose is primarily to provide an expression evaluation and data inspection service.  How expression evaluation works is an article in itself but suffice it to say that it converts the string to a very low level AST then walks the nodes bottom up and evaluating the expressions using the ICorDebug APIs.  The EE component has no UI and is simply a data provider for the core debugger services.  

The design philosophy for Both VB.Net and C# is to have the highest level of fidelity between expressions evaluated in the EE and the actual running program.  To do otherwise would lead to extremely confusing results for users.  When spec'ing feature support in the VB.Net EE we start from the point of 100% fidelity, determine the problems with this design (if any) and then start the difficult process of making compromises.

LINQ expressions are very different than any other expression previously allowed in the EE window because of the features interaction with metadata.  All LINQ expressions require the generation or manipulation of metadata to support the underlying lambda and/or closure.  Adding support for this is one of the biggest hurdles to getting LINQ (and other features) into the EE.  

Evaluating a LINQ expression is actually much closer to an ENC operation than a traditional EE one.

Currently the EE's have no capacity for generating metadata, only interpreting it.  Operations which mutate or generate metadata have traditionally only been allowed via the ENC service.  Getting LINQ to work in the EE with true fidelity would require at least a minimal amount of ENC feature work.

Without getting into too much detail, lets enumerate the** new** major features necessary to evaluate a LINQ expression in the EE with true fidelity to the running program.  To simplify things, we'll start by assuming there is no other LINQ expression used in the current method and the method is only being executed at most once at any given time in the process.  

  1. A metadata generation service to support the backing for closures and lambda expressions 
  2. Convert expressions typed in the EE into IL [^2] 
  3. ENC support for metadata to push the new metadata for closures and lambdas into the currently executing assembly 
  4. ENC support for method body IL to remove lifted variables from the current method and redirect the references inside the closure

Issues #1 and #2 are for the most part internal architecture issues and can be solved via normal processes of code base refactoring and adding new features to an existing component.   I don't mean to imply these problems are cheap (in fact they are relatively expensive)  But fixing these is somewhat of an understood quantity.

Issues #3 and #4 are where the problems start.  As implemented EE's do not have capability to create or modify metadata in the running process (that is the job of the ENC service).  EE's do have access to the underlying CLR ENC APIs so it is possible to implement ENC operations in the EE.  It's just simply not been done yet.

Wait!  Why not reuse our ENC implementation in the EE?  Unfortunately the ENC service is currently tied heavily to our in memory IDE compiler and many other IDE / STA features.  It in fact lives in a completely separate DLL, separate COM apartment and works on a different symbol table than the EE.  

More fundamental though is that it's designed for a completely different purpose.  ENC is designed to track edits in live code, determining the differences and applying them to the running program.  The hypothetical EE feature would be tracking expressions that modify a running DLL for which code is not guaranteed (and not likely) to be available and applying the difference to the running program.  There are some similarities but the differences are significant enough to make code reuse have limited value.

Some people may wonder why it's necessary to implement #4.  Couldn't we just avoid removing the variable from the current method and make the feature cheaper?  This is possible but it would cause a significant fidelity difference in the feature.  Any mutations of the local variable within the LINQ expression would not be visible on the stack frame as it would if the LINQ expression was present in the original program.

It's easy to think of this ENC in the EE as just the same type of cost as #1 and #2 (in many ways it is).  However taking advantage of the CLR ENC APIs in the EE also means that we inherit it's limitations as well.  ENC as as implemented in the CLR has many limitations which fly in the face of LINQ.  In particular the following ENC limitations present major problems ([ENC limitations reference](http://blogs.msdn.com/jmstall/archive/2005/02/19/376666.aspx)).

  1. Cannot add members to a value type.  This prevents evaluating LINQ when stopped in a value type method 
  2. Cannot remove locals from a function.  This is an implementation of LINQ but we could work around this problem by changing the IL to simply no longer accessing the local variables. 
  3. Cannot change anything in a generic type.  This prevents evaluating LINQ when stopped in a generic type. 
  4. Cannot specify an initial value for newly added fields. 
  5. Allowable ENC operations differ between the top of the stack and operations elsewhere within the stack 
  6. Modification of a non-top stack frame cannot significantly edit the current function call.  So if a LINQ expression captures a variable used in that call (think ref passing) it would likely be unable to be evaluated.

So even if we implemented everything possible on the language service side the resulting feature would be limited in several impactful ways.  Additionally these limitations are somewhat orthogonal to the current limitations EE's face and would require a bit of user education.  And this is only for the most basic LINQ feature under unrealistic scenarios.

Lets now consider the problems of evaluating a LINQ expression when the current method already contains a LINQ expression that lifts at least 1 variable.  Evaluating a new expression at the same scope would require the modification of the current closure to maintain fidelity as opposed to generating a new one.  This brings along with it a couple more problems.

  1. A lambda expression which uses 2 variables, 1 of which is captured in an existing lambda expression.  To maintain fidelity we would have to modify an existing closure signature to contain the new variable. 

Often times generated closures are generic so we would run straight into ENC limitation #3. Additionally we would need the newly added field to have the same value as it has in the current method which runs us into ENC limitation #4. Now also consider that a closure instance can live much longer than the method in which it was created. For those closures no stack value is available so what value should we give fields in that instance?  Ideally it should have the value of the variable at the point the method exited but realistically that's not possible.

  2. A lambda expression which uses 1 variable in a method where an existing lambda expression captures that same variable and another.  To maintain fidelity we would have to know about this and fake capture the second variable as well.

Now consider all of the problems above and consider the scenario where there are multiple threads and multiple instances of the current method active in the program.  How to determine which closure instance belongs to which thread, and just as important which stack frame on which thread, with respect to initializing values?

None of the issues are an unsolvable problem but they do represent a significant cost to the feature.  And once again even if we added all of these features to the EE, ENC limitations would significantly limit the usefulness of the resulting feature.

Does this mean that LINQ, or any future metadata requiring expression, will never be added to the debugger window?  Absolutely not.  We've just hit the difficult stage of making compromises on the level of fidelity in the feature.  If you back off of true fidelity in a few small ways the resulting feature, while still very expensive, is significantly cheaper and removes many of the limitations imposed by ENC.   This **hypothetical** feature will be discussed in my next article.

[^1]: For those interested the returned interface is [IDebugProperty2](http://msdn.microsoft.com/en-us/library/bb161287\(VS.80\).aspx)

[^2]: Right now expressions are converted to a tree form slightly above IL and they are interpreted using the ICorDebug APIs.  Converting all the way down to IL requires a lot more work


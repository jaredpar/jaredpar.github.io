---
layout: post
---
Occasionally the debate will come as to when it's OK to use type inference in
order to declare a variable.?? There appear to be three groups in this debate.

  1. Whenever it's possible
  2. Only when it's absolutely clear what the type is 
  3. Never, type inference is evil

I fall into camp #1 and here are my reasons

  * It does not reduce type safety.?? This doesn't allow for any late binding, type unsafe functions or the like.?? It simply lets the compiler chose the type for you.
  * It will actually increase type safety in your code.?? The best example of this is the foreach statement on non-generic IEnumerable instances.?? These foreach statements are all technically unsafe because the compiler must do a cast of the Current member under the hood.?? This declaration looks no different than the type safe generic version of IEnumerable.?? Using var will force you to write an explicit cast.????

> foreach (SomeType cur in col)

> foreach ( var cur in col.Cast<SomeType>())

  * Maintains the principles of DRY.?? This is mostly true for cases where you have an explicit constructor on the RHS.
  * For some types, this is a requirement in order to use the type (anonymous types for instance).?? I'm a big fan of consistency and since I must have some instances use type inference, I'd like to use them everywhere.??
  * Makes refactoring easier.?? I re-factor, a lot.?? I constantly split up or rename types.?? Often in such a way that refactoring tools don't fixup all of the problems.?? With var declarations I don't have to worry because they just properly infer their new type and happily chug along.?? For explicit type cases I have to manually update all of the type names.??
  * Less typing with no loss of functionality.

The best argument I've heard against type inference is that it reduces
readability since you can't look at a variable and know it's type.?? True, but
just hover over the declaration and the IDE will display the type.?? Yes this
is not possible with a non-IDE editor but how often do you use one?


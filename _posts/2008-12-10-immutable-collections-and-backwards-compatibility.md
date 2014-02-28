---
layout: post
---
When developing my [immutable collections
library](http://code.msdn.microsoft.com/RantPack), I spent a lot of time on
usability.  After all, if a library is not useful then what???s the point?

A big portion of usability is being able to work with existing frameworks and
technologies.  For .Net and collections that means items like Data binding,
LINQ etc ???  Without integrating into popular technologies the usefulness of a
particular library is severely impacted and hence usability decreases.

Most of the existing collection based infrastructures use the .Net collection
interfaces as their form of abstraction.  The most straight forward way to
ensure compatibility is to implement these interfaces on the collections in
question.  In particular [ICollection<T>](http://msdn.microsoft.com/en-
us/library/92t2ye13.aspx), [IList<T>](http://msdn.microsoft.com/en-
us/library/5y536ey6.aspx) and [IEnumerable<T>](http://msdn.microsoft.com/en-
us/library/9eekhta0.aspx) are the main abstractions.  Lets investigate which
ones an Immutable collection should be implementing in order to effectively
integrate into existing collection based infrastructures.

**IEnumerable<T>**

This is the easiest decision.  IEnumerable<T> represents a read only, one
element at time view on a sequence of objects.  Immutable collections can
easily and reliably implement a IEnumerable<T>.  This is a no brainer.
Implement.

**ICollection<T>**

This interfaces represents a general collection class.  Unfortunately this
interface is meant to represent a mutable collection class and implements such
methods as Add, Clear and Remove.  These methods cannot be implemented on an
Immutable collection given the current design.  All three of these methods are
void returning methods because the collection is meant to be changed in place.
Immutable collections can support these operations but it involves returning a
new instance of the collection.

    
    
    public sealed class ImmutableCollection<T> : ICollection<T> {


        public ImmutableCollection<T> Add(T item) {


            // Actually add 


            // ...


        }


    


        #region ICollection<T> Members


    


        void ICollection<T>.Add(T item) {


            var created = this.Add(item);


            // What to do with created???


        }


    


        ...


    }

But wait!  The interface does support a property named
[IsReadOnly](http://msdn.microsoft.com/en-us/library/0cfatk9t.aspx).  The
intention of this property is to allow an interface to programmatically
declare they do not support modifications.  A read only collection can just
implement this interface, throw a
[NotSupportedException](http://msdn.microsoft.com/en-
us/library/system.notsupportedexception.aspx) for all of the mutable methods
and return true for IsReadOnly and presto we have a suitable interface for an
immutable collection.

Or do we?

The design for ICollection<T> with respect to read only or immutable
collections is not optimal.  It attempts to combine to separate behaviors into
a single interface: mutable and readonly view of a collection.  Dual purpose
interfaces run into problems because it???s impossible to separate out the
behaviors at compile time.  This is especially problematic when the behaviors
are conflicting.  There is no way a read only collection can prevent itself
from being passed to a function that expects a mutable collection at compile
time.  Nor can a consumer who intends to mutate a collection prevent a read-
only collection from being passed.

    
    
    static void DisplayForEdit<T>(ICollection<T> col) {


        // ...


        m_clearButton.Click += (x, y) => col.Clear(); 


    }


    


    static void Example1() {


        ImmutableCollection<int> col = ImmutableCollection.Create(new int[] { 1, 2, 3, 4 });


        DisplayForEdit(col);    // Will fail as soon as Clear is clicked


    }

But isn???t it the responsibility of the user of ICollection<T> to verify that
IsReadOnly is false before mutating a instance?  Given the current design of
ICollection<T> it is indeed both the responsibility of the consumer to verify
this and the implementer to ensure they are not called incorrectly.  The
problem with putting responsibility on the consumer though is they have to 1)
know about read only uses of ICollection<T> and 2) actually care about it.

A quick search of the BCL with reflector can give us evidence of how much
consumers actually check for the read only scenario.  For the search I used
mscorlib, System, System.Xml, System.Data, System.Drawing and System.Core and
System.Windows.Forms.  And the number of classes which actually take into
account ICollection<T>.IsReadOnly is ??? 1.
System.Collections.ObjectModel.Collection<T>.  That???s it.

So even if an immutable collection implements this interface in a read-only
fashion there???s little chance anyone will be checking for it.

**IList<T>**

IList<T> inherits from ICollection<T> and hence suffers from all of the same
problems

**Decision Time**

In order to facilitate usability with existing frameworks immutable
collections are forced to implement interfaces for which they have no possible
way of implementing properly.  If collections implement these interfaces they
will be trading usability for compile time validation.  Even worse is the
conversion is implicit which prevents even basic searches for places this
conversion occurs.  This is a heavy price to pay for compatibility.

After debating this for awhile I decided that loss of compile time validation
was a too heavy of a price to pay for the default scenario.  But trading away
usability was also unacceptable.  As a compromise I opted for adding a
compatibility layer to the collections.  Instead of implementing the
ICollection<T> and IList<T> collections directly I created a set of proxy
objects that implement the interfaces on behalf of the immutable collections.

In order to centralize this effort I created a factory class,
CollectionUtility, which contains appropriate overloads for all of my
immutable collection classes [1].

    
    
    public static class CollectionUtility {


        public static IEnumerable<T> CreateEmptyEnumerable<T>();


        public static IEnumerable<T> CreateEnumerable<T>(T value);


        public static ICollection<T> CreateICollection<T>(IReadOnlyCollection<T> col);


        public static IDictionary<TKey, TValue> CreateIDictionary<TKey, TValue>(IReadOnlyMap<TKey, TValue> map);


        public static IList<T> CreateIList<T>(IReadOnlyList<T> list);


        public static ICollection CreateObjectICollection<T>(IReadOnlyCollection<T> col);


        public static IDictionary CreateObjectIDictionary<TKey, TValue>(IReadOnlyMap<TKey, TValue> map);


        public static IList CreateObjectIList<T>(IReadOnlyList<T> list);


        public static IEnumerable<int> GetRangeCount(int start, int count);


    }

The proxy objects live as private inner classes inside CollectionUtility.
They implement the collection interfaces in the most read-only way possible.
When confronted with mutating calls, the proxies throw
[NotSupportedException](http://msdn.microsoft.com/en-
us/library/system.notsupportedexception.aspx).

So at the end of the day I have compile time validation for immutable
collections.  If a developer wants to use them in a less than safe scenario it
requires an explicit conversion.  
    
    
    static void Example2() { 


      var col = ImmutableCollection.Create(new int[] { 1, 2, 3, 4 }); 


      // Still fails, but explicit conversion required 


      DisplayForEdit(CollectionUtility.CreateICollection(col)); 


      }

I feel like this as an appropriate tradeoff.   In the worst case scenario, a
developer can search for all accesses of the CollectionUtility class and find
places where a proxy is being created.

Next time, lets take a look at a different way of approaching an interface
hierarchy for a set of collections.  One that will allow us to avoid this
problem altogether going forward.

[1] It actually contains overloads for a set of truly read only collection
interfaces that I wrote for my library but we???ll get to that another time.

Edit: Updated the exception to be NotSupportedException


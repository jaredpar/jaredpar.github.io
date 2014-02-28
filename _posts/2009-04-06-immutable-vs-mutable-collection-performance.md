---
layout: post
---
One argument I commonly hear against immutable collections is they are slow.
I???ve held the opposite belief for some time but shamefully had yet to look at
actual numbers on the CLR.?? Tonight I decided to change that by benchmarking
one of [my immutable collections](http://code.msdn.com/BclExtras) against a
mutable collection in the BCL.?? The goal is not to decide the overall best
collection but instead to get a sense of how they perform relative to each
other in certain scenarios.

For the immutable version, I chose to use ImmutableCollection.?? This class is
a slight variation of Eric Lippert???s [Double Ended
Queue](http://blogs.msdn.com/ericlippert/archive/2008/02/12/immutability-in-c
-part-eleven-a-working-double-ended-queue.aspx) implementation.?? The core
algorithm is the same but the style was changed to be more inline with other
immutable collections I own. For the mutable class I chose to use the ever
popular [List<T>](http://msdn.microsoft.com/en-us/library/6sh2ey19.aspx)
collection.

I chose to examine the following scenarios that I commonly use with collection
style classes.

  * Adding to the end of the collection 
  * Adding to the front of the collection 
  * Removing from the end of the collection 
  * Removing from the beginning of the collection 

Each scenario was run against collections of 100, 1000 and 10000 elements.
For each count, the run was executed 1000 times and the total and average time
was calculated.?? The full code for the benchmark is available at the end of
this post.

**Looking at the data**

Now before I get into the results, please assume the usual caveats that come
with any benchmark.?? That is, approach it with a skeptical eye.?? These
scenarios are obviously not something I do **exactly **in everyday programming
(especially removing thousands of elements from the front of List<T>).
However they are representative of general operations that I do use.?? Also I
find it interesting to see how the collections perform relative to each other
in extreme scenarios.

Most of the results were unsurprising.?? Remove from end is a very simple
operation on a List<T>.?? It comes down to a bounds check, decrementing an
index and updating a couple of internal state variables.???? Removing the end of
an immutable collection requires considerable updating of the internal
structure.?? It ends up being roughly 1 order of magnitude slower.?????? Adding to
the end has similar implementation and numbers.

Operations on the front of the list were significantly slower on List<T> than
ImmutableCollection for suitably large collections.?? This is unsurprising
given that removal and insertion at the front of a List<T> requires all of the
other elements in the underlying array to be shifted up or down.?? This is a
non-trivial operation and is evident in the benchmark.

The most interesting item however, is to look at how each collection scales.
In almost all scenarios, ImmutableCollection scaled very closely to the size
of the input.?? That is, an order of magnitude more input resulted in an order
of magnitude of more time.?? List<T> does not have that behavior for all
scenarios.?? Scenarios dealing with the front of the collection saw time rises
faster relative to input size.?? In fact there is a very dramatic jump in both
front scenarios between 1000 and 1000 elements.?? Each case resulted in roughly
2 orders of magnitude more time.

**Conclusion**

Winner of each category ???

  * Add to End: List<T>
  * Add to Front: ImmutableCollection<T>
  * Remove from End: List<T>
  * Remove from Front: ImmutableCollection<T>

No single benchmark is definitive and this one won???t change that.?? This
benchmark says nothing about the general use of the two classes.?? However it
can provide some insight into these specific scenarios.?? It also serves as
some level of proof that immutable collections can have acceptable performance
for these scenarios.

**Data**
    
    
    Add to End 100 Elements


           List: Total: 00:00:00.0060473 Average: 00:00:00.0000060


      Immutable: Total: 00:00:00.0267079 Average: 00:00:00.0000267


    Add to End 1000 Elements


           List: Total: 00:00:00.0337505 Average: 00:00:00.0000337


      Immutable: Total: 00:00:00.2240444 Average: 00:00:00.0002240


    Add to End 10000 Elements


           List: Total: 00:00:00.4266014 Average: 00:00:00.0004266


      Immutable: Total: 00:00:02.6715789 Average: 00:00:00.0026715


    Add to Front 100 Elements


           List: Total: 00:00:00.0162186 Average: 00:00:00.0000162


      Immutable: Total: 00:00:00.0213764 Average: 00:00:00.0000213


    Add to Front 1000 Elements


           List: Total: 00:00:00.4028523 Average: 00:00:00.0004028


      Immutable: Total: 00:00:00.2055935 Average: 00:00:00.0002055


    Add to Front 10000 Elements


           List: Total: 00:00:38.5943722 Average: 00:00:00.0385943


      Immutable: Total: 00:00:02.6212590 Average: 00:00:00.0026212


    Remove From End 100 Elements


           List: Total: 00:00:00.0031299 Average: 00:00:00.0000031


      Immutable: Total: 00:00:00.0213737 Average: 00:00:00.0000213


    Remove From End 1000 Elements


           List: Total: 00:00:00.0187998 Average: 00:00:00.0000187


      Immutable: Total: 00:00:00.1623739 Average: 00:00:00.0001623


    Remove From End 10000 Elements


           List: Total: 00:00:00.1773381 Average: 00:00:00.0001773


      Immutable: Total: 00:00:01.9615781 Average: 00:00:00.0019615


    Remove From Front 100 Elements


           List: Total: 00:00:00.0142981 Average: 00:00:00.0000142


      Immutable: Total: 00:00:00.0192679 Average: 00:00:00.0000192


    Remove From Front 1000 Elements


           List: Total: 00:00:00.4407993 Average: 00:00:00.0004407


      Immutable: Total: 00:00:00.1879243 Average: 00:00:00.0001879


    Remove From Front 10000 Elements


           List: Total: 00:00:39.7832085 Average: 00:00:00.0397832


      Immutable: Total: 00:00:02.2451406 Average: 00:00:00.0022451

**The Code**
    
    
    public class Program {


        public static void ImmutableCollectionAddToEnd(List<string> list) {


            var col = ImmutableCollection<string>.Empty;


            foreach (var item in list) {


                col = col.AddBack(item);


            }


        }


        public static void ListAddToEnd(List<string> list) {


            var col = new List<string>();


            foreach (var item in list) {


                col.Add(item);


            }


        }


        public static void RunAddToEnd(int count) {


            var list = Enumerable.Range(0, count).Select(x => x.ToString()).ToList();


            Console.WriteLine("Add to End {0} Elements", count);


            RunScenario("List", ListAddToEnd, () => list);


            RunScenario("Immutable", ImmutableCollectionAddToEnd, () => list);


        }


        public static void ImmutableCollectionAddToFront(List<string> list) {


            var col = ImmutableCollection<string>.Empty;


            foreach (var item in list) {


                col = col.AddFront(item);


            }


        }


        public static void ListAddToFront(List<string> list) {


            var col = new List<string>();


            foreach (var item in list) {


                col.Insert(0, item);


            }


        }


        public static void RunAddToFront(int count) {


            var list = Enumerable.Range(0, count).Select(x => x.ToString()).ToList();


            Console.WriteLine("Add to Front {0} Elements", count);


            RunScenario("List", ListAddToFront, () => list);


            RunScenario("Immutable", ImmutableCollectionAddToFront, () => list);


        }


        public static void ImmutableCollectionRemoveFromEnd(ImmutableCollection<string> col) {


            while (!col.IsEmpty) {


                col = col.RemoveBack();


            }


        }


        public static void ListRemoveFromEnd(List<string> list) {


            while (list.Count > 0) {


                list.RemoveAt(list.Count - 1);


            }


        }


        public static void RunRemoveFromEnd(int count) {


            Func<List<string>> listInputFunc = () => Enumerable.Range(0, count).Select(x => x.ToString()).ToList();


            Func<ImmutableCollection<string>> colInputFunc = () => ImmutableCollection.Create(listInputFunc());


            Console.WriteLine("Remove From End {0} Elements", count);


            RunScenario("List", ListRemoveFromEnd, listInputFunc);


            RunScenario("Immutable", ImmutableCollectionRemoveFromEnd, colInputFunc);


        }


        public static void ImmutableCollectionRemoveFromFront(ImmutableCollection<string> col) {


            while (!col.IsEmpty) {


                col = col.RemoveFront();


            }


        }


        public static void ListRemoveFromFront(List<string> col) {


            while (col.Count > 0) {


                col.RemoveAt(0);


            }


        }


        public static void RunRemoveFromFront(int count) {


            Func<List<string>> listInputFunc = () => Enumerable.Range(0, count).Select(x => x.ToString()).ToList();


            Func<ImmutableCollection<string>> colInputFunc = () => ImmutableCollection.Create(listInputFunc());


            Console.WriteLine("Remove From Front {0} Elements", count);


            RunScenario("List", ListRemoveFromFront, listInputFunc);


            RunScenario("Immutable", ImmutableCollectionRemoveFromFront, colInputFunc);


        }


        public static void RunScenario<T>(string description, Action<T> del, Func<T> getInputFunc) {


            // Run once to jit


            del(getInputFunc());


            const int times = 1000;


            var total = new TimeSpan();


            for (var i = 0; i < times; i++) {


                // get the input outside the timer so input creation is not calculated 


                var input = getInputFunc();


                var watch = new Stopwatch();


                watch.Start();


                del(input);


                watch.Stop();


                total += watch.Elapsed;


            }


            var average = TimeSpan.FromTicks(total.Ticks / times);


            Console.WriteLine("{0,11}: Total: {1} Average: {2}", description, total, average);


        }


        static void Main(string[] args) {


            var list = new int[] { 100, 1000, 10000 };


            list.ForEach(RunAddToEnd);


            list.ForEach(RunAddToFront);


            list.ForEach(RunRemoveFromEnd);


            list.ForEach(RunRemoveFromFront);


        }


    }


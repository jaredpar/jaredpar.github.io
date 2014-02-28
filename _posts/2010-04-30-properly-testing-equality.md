---
layout: post
---
Getting equality correct on a .Net type is a fairly involved process involving
adherence to a large set of rules in order to be considered correct.
Including

  * Object.Equals overrides on reference types must return false for null values 
  * Object.Equals overrides must return false for incompatible types 
  * Excluding null cases x.Equals(y) must be the same as y.Equals(x) 
  * Excluding null cases (x.Equals(y) && y.Equals(z)) is true only if x.Equals(z) 
  * If operator == or overloaded 
    * Both == and != should be overloaded or none 
    * Operator == must handle the left side being null 
    * Operator == should mimic Object.Equals in all cases where the left side is not null 
    * Operator != must handle the left side being null 
    * Operator != should mimic !Object.Equals in all cases where the left side is not null 
  * If two values are equal according to Object.Equals they must have matching returns for GetHashCode 

I???m sure I missed one or two subtle ones but these are the major players.?? It
gets even more fun when you add in IEquatable<T> to the mix.

Luckily correctly implementing equality is fairly straight forward and most
template code available on the web respects the above rules.?? However it???s
easy to miss a corner case and add hard to track down bugs.

I???m not satisfied by simply following a standard template and hoping I got it
right.?? I only sleep easy if I???ve tested these cases.?? Yet testing all of
these cases is very tedious and involves quite a bit of code that screams for
an abstraction.?? As a new type author I simply want to provide a collection of
units which associate a value and corresponding equal or not equal values and
let the abstraction verify I properly implemented equality semantics.

The first step is defining a type to encapsulate a value and set of equal or
not equal values.

    
    
    public class EqualityUnit<T> {


        private static ReadOnlyCollection<T> EmptyCollection = new ReadOnlyCollection<T>(new T[] { });


    


        public readonly T Value;


        public readonly ReadOnlyCollection<T> EqualValues;


        public readonly ReadOnlyCollection<T> NotEqualValues;


        public IEnumerable<T> AllValues {


            get { return Enumerable.Repeat(Value, 1).Concat(EqualValues).Concat(NotEqualValues); }


        }


        public EqualityUnit(T value) {


            Value = value;


            EqualValues = EmptyCollection;


            NotEqualValues = EmptyCollection;


        }


        public EqualityUnit(


            T value,


            ReadOnlyCollection<T> equalValues,


            ReadOnlyCollection<T> notEqualValues) {


            Value = value;


            EqualValues = equalValues;


            NotEqualValues = notEqualValues;


        }


        public EqualityUnit<T> WithEqualValues(params T[] equalValues) {


            return new EqualityUnit<T>(


                Value,


                EqualValues.Concat(equalValues).ToList().AsReadOnly(),


                NotEqualValues);


        }


        public EqualityUnit<T> WithNotEqualValues(params T[] notEqualValues) {


            return new EqualityUnit<T>(


                Value,


                EqualValues,


                NotEqualValues.Concat(notEqualValues).ToList().AsReadOnly());


        }


    }


    


    public static class EqualityUnit {


        public static EqualityUnit<T> Create<T>(T value) {


            return new EqualityUnit<T>(value);


        }


    }

I chose a fluent interface design here because it makes the usage code very
readable.?? For example

    
    
    var unit = EqualityUnit


        .Create(new MyType(42))


        .WithEqualValues(new MyType(42))


        .WithNotEqualValues(new MyType(13));

Now that we have the data defined we need to follow through with the actual
test code.?? Most of it is very straight forward enforcement of the above said
rules.?? The only trick part is how to test operator == and !=.???? The testing
class is necessarily generic but neither == or != can be used against open
generic types.?? Instead we must use them against the non-generic types.

This can be solved by having the calling code provide 2 lambda expressions of
type Func<T,T,bool> which call the == and != operator.

    
    
    EqualityUtil.RunAll(


        (x, y) => x == y,


        (x, y) => x != y,

This is boiler plate code that has to be repeated for every caller but it???s
small enough to not be that much of a burden.???? Now finally the code.

    
    
    public sealed class EqualityUtil<T> {


        private readonly ReadOnlyCollection<EqualityUnit<T>> _equalityUnits;


        private readonly Func<T, T, bool> _compareWithEqualityOperator;


        public readonly Func<T, T, bool> _compareWithInequalityOperator;


    


        public EqualityUtil(


            IEnumerable<EqualityUnit<T>> equalityUnits,


            Func<T, T, bool> compEquality,


            Func<T, T, bool> compInequality) {


            _equalityUnits = equalityUnits.ToList().AsReadOnly();


            _compareWithEqualityOperator = compEquality;


            _compareWithInequalityOperator = compInequality;


        }


    


        public void RunAll(


            bool skipOperators = false,


            bool skipEquatable = false) {


            if (!skipOperators) {


                EqualityOperator();


                EqualityOperatorCheckNull();


                InEqualityOperator();


                InEqualityOperatorCheckNull();


            }


    


            if (!skipEquatable) {


                ImplementsIEquatable();


                EquatableEquals();


                EquatableEqualsCheckNull();


            }


    


            ObjectEquals();


            ObjectEqualsCheckNull();


            ObjectEqualsDifferentType();


            GetHashCodeSemantics();


        }


    


        private void EqualityOperator() {


            foreach (var unit in _equalityUnits) {


                foreach (var value in unit.EqualValues) {


                    Assert.IsTrue(_compareWithEqualityOperator(unit.Value, value));


                    Assert.IsTrue(_compareWithEqualityOperator(value, unit.Value));


                }


    


                foreach (var value in unit.NotEqualValues) {


                    Assert.IsFalse(_compareWithEqualityOperator(unit.Value, value));


                    Assert.IsFalse(_compareWithEqualityOperator(value, unit.Value));


                }


            }


        }


    


        private void EqualityOperatorCheckNull() {


            if (typeof(T).IsValueType) {


                return;


            }


    


            foreach (var value in _equalityUnits.SelectMany(x => x.AllValues)) {


                if (!Object.ReferenceEquals(value, null)) {


                    Assert.IsFalse(_compareWithEqualityOperator(default(T), value));


                    Assert.IsFalse(_compareWithEqualityOperator(value, default(T)));


                }


            }


        }


    


        private void InEqualityOperator() {


            foreach (var unit in _equalityUnits) {


                foreach (var value in unit.EqualValues) {


                    Assert.IsFalse(_compareWithInequalityOperator(unit.Value, value));


                    Assert.IsFalse(_compareWithInequalityOperator(value, unit.Value));


                }


    


                foreach (var value in unit.NotEqualValues) {


                    Assert.IsTrue(_compareWithInequalityOperator(unit.Value, value));


                    Assert.IsTrue(_compareWithInequalityOperator(value, unit.Value));


                }


            }


        }


    


        private void InEqualityOperatorCheckNull() {


            if (typeof(T).IsValueType) {


                return;


            }


            foreach (var value in _equalityUnits.SelectMany(x => x.AllValues)) {


                if (!Object.ReferenceEquals(value, null)) {


                    Assert.IsTrue(_compareWithInequalityOperator(default(T), value));


                    Assert.IsTrue(_compareWithInequalityOperator(value, default(T)));


                }


            }


        }


    


        private void ImplementsIEquatable() {


            var type = typeof(T);


            var targetType = typeof(IEquatable<T>);


            Assert.IsTrue(type.GetInterfaces().Contains(targetType));


        }


    


        private void ObjectEquals() {


            foreach (var unit in _equalityUnits) {


                var unitValue = unit.Value;


                foreach (var value in unit.EqualValues) {


                    Assert.IsTrue(unitValue.Equals(value));


                    Assert.IsTrue(value.Equals(unitValue));


                }


                foreach (var value in unit.NotEqualValues) {


                    Assert.IsFalse(unitValue.Equals(value));


                    Assert.IsFalse(value.Equals(unitValue));


                }


            }


        }


    


        /// <summary>


        /// Comparison with Null should be false for reference types


        /// </summary>


        private void ObjectEqualsCheckNull() {


            if (typeof(T).IsValueType) {


                return;


            }


    


            var allValues = _equalityUnits.SelectMany(x => x.AllValues);


            foreach (var value in allValues) {


                Assert.IsFalse(value.Equals(null));


            }


        }


    


        private sealed class NotAccessible { } 


    


        /// <summary>


        /// Passing a value of a different type should just return false


        /// </summary>


        private void ObjectEqualsDifferentType() {


            var allValues = _equalityUnits.SelectMany(x => x.AllValues);


            foreach (var value in allValues) {


                Assert.IsFalse(value.Equals(new NotAccessible()));


            }


        }


    


        private void GetHashCodeSemantics() {


            foreach (var unit in _equalityUnits) {


                foreach (var value in unit.EqualValues) {


                    Assert.AreEqual(value.GetHashCode(), unit.Value.GetHashCode());


                }


            }


        }


    


        private void EquatableEquals() {


            foreach (var unit in _equalityUnits) {


                var equatableUnit = (IEquatable<T>)unit.Value;


                foreach (var value in unit.EqualValues) {


                    Assert.IsTrue(equatableUnit.Equals(value));


                    var equatableValue = (IEquatable<T>)value;


                    Assert.IsTrue(equatableValue.Equals(unit.Value));


                }


    


                foreach (var value in unit.NotEqualValues) {


                    Assert.IsFalse(equatableUnit.Equals(value));


                    var equatableValue = (IEquatable<T>)value;


                    Assert.IsFalse(equatableValue.Equals(unit.Value));


                }


            }


        }


    


        /// <summary>


        /// If T is a reference type, null should return false in all cases


        /// </summary>


        private void EquatableEqualsCheckNull() {


            if (typeof(T).IsValueType) {


                return;


            }


    


            foreach (var cur in _equalityUnits.SelectMany(x => x.AllValues)) {


                var value = (IEquatable<T>)cur;


                Assert.IsFalse(value.Equals(null));


            }


        }


    }


    


    public static class EqualityUtil {


        public static void RunAll<T>(


            Func<T, T, bool> compEqualsOperator,


            Func<T, T, bool> compNotEqualsOperator,


            bool skipOperators,


            bool skipEquatable,


            params EqualityUnit<T>[] values) {


            var util = new EqualityUtil<T>(values, compEqualsOperator, compNotEqualsOperator);


            util.RunAll(skipOperators: skipOperators, skipEquatable: skipEquatable);


        }


    


        public static void RunAll<T>(


            Func<T, T, bool> compEqualsOperator,


            Func<T, T, bool> compNotEqualsOperator,


            params EqualityUnit<T>[] values) {


            RunAll(compEqualsOperator, compNotEqualsOperator, skipEquatable: false, skipOperators: false, values: values);


        }


    }

And what would any code, including test framework code be without a few test
cases?

    
    
    [TestFixture]


    public class EqualityUtilTesting {


    


        [Test]


        public void EqualityWithIntegers() {


            EqualityUtil.RunAll(


                (x, y) => x == y,


                (x, y) => x != y,


                EqualityUnit.Create(1).WithEqualValues(1).WithNotEqualValues(2),


                EqualityUnit.Create(42).WithNotEqualValues(13));


        }


    


        [Test]


        public void EqualityWithStrings() {


            EqualityUtil.RunAll(


                (x, y) => x == y,


                (x, y) => x != y,


                EqualityUnit.Create("foo").WithEqualValues("foo").WithNotEqualValues("no"),


                EqualityUnit.Create("FOO").WithNotEqualValues("foo"));


        }


    }


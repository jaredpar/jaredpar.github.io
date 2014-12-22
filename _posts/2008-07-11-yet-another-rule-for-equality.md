---
layout: post
---
"If you implement equality in a child class, including operators, you must implement the equality operators in the base class."

Unfortunately this is another case of learn the hard way but makes sense when you think about it.  The below code snippet is an example of the problem that I hit.  Even though I have equality properly defined in Child, the equality check goes through Parent.  As such the C# compiler will perform the default comparison which is reference equality.

The simple fix is to add the operator ==/!= definitions to Parent which call through EqualityComparer<Parent>.Default.  This will end up calling obj.Equals and equality will function correctly.  

While this is intuitive when you think about it, it's an easy trap to fall into.  It would be nice if there was a Compiler/FXCop warning here.

``` csharp
class Parent {
}
class Child : Parent{
    public readonly int Field1;
    public Child(int value) {
        Field1 = value;
    }

    public override int GetHashCode() {
        return Field1;
    }
    public override bool Equals(object obj) {
        var other = obj as Child;
        if (other == null) {
            return false;
        }
        return other.Field1 == Field1;
    }
    public static bool operator ==(Child left, Child right) {
        return EqualityComparer<Child>.Default.Equals(left, right);
    }

    public static bool operator !=(Child left, Child right) {
        return !EqualityComparer<Child>.Default.Equals(left, right);
    }
}

class Program {
    static void Main(string[] args) {
        Child child1 = new Child(42);
        Child child2 = new Child(42);
        Parent parent1 = child1;
        Parent parent2 = child2;
        bool isChildEqual = child2 == child1;       // True
        bool isParentEqual = parent1 == parent2;    // False
    }
}
```

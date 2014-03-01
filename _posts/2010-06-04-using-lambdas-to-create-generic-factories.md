---
layout: post
---
One item I find to be limiting in C# is the [new generic
constraint.](http://msdn.microsoft.com/en-us/library/sd2w2ew5\(VS.80\).aspx)
The syntax construct specifies that the type backing a given generic parameter
contains a parameter less constructor.'? It allows methods to create instances
of generic parameters in a type safe manner.

    
    
    public static void Example<T>() 


        where T : new()


    {


        var value = new T();


        Process(value);


    }

I find though that I very rarely want this capability. The object can't be
provided any initial state since you can't give it any values to the
constructor. It's really only useful if you want to create and then mutate a
given object.

Typically I prefer to deal with immutable data or at least types which build
upon other information. Hence my types tend to have constructors which take
at least one piece of information. In this case the new constraint is of no
value because it can't be used to describe arbitrary constructor signatures
but is limited to only a parameter less constructor.

    
    
    public static void Example<T>()


        where T : new(string) // Not possible!!!


    {


        var value = new T("some data");


    


    }

Originally when I faced this situation I ran to the factory pattern. I
created a nice IFactory<T> interface which had a Create method taking a
string, and modified the methods to take this type instead.

    
    
    public static void Example<T>(IFactory<T> factory) {


        var value = factory.Create("some data");


    }

This works and there is nothing wrong with it. Except of course it's an
extremely verbose solution. Every time I want to use the method with a new
type I have to create a new type which implements IFactory<MyNewType> just to
call this method.'? This is very tiresome and gets frustrating very fast with
broad object hierarchies.

Fortunately there is a much lighter weight solution to this problem: lambda
expressions. All we need in this instance is a method which given one or more
pieces of input returns a new instance of T. How this is implemented is of no
concern to the method. This can easily be done via a delegate.

    
    
    public static void Example<T>(Func<string, T> createInstance) {


        var value = createInstance("some data");


    }

Now the caller can provide the contract with a simple light weight lambda
expression

    
    
    Example(data => new Widget(data));


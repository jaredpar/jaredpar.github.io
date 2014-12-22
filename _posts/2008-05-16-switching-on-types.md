---
layout: post
---
One action I find frustrating in C# is where a particular action needs to be taken based off of the type of a particular object.  Ideally I would like to solve this with a switch statement but switch statements only support constant expressions in C# so no luck there.  Previously I've had to resort to ugly looking code like the following.

    
``` csharp
Type t = sender.GetType();
if (t == typeof(Button)) {
    var realObj = (Button)sender;
    // Do Something
}
else if (t == typeof(CheckBox)) {
    var realObj = (CheckBox)sender;
    // Do something else
}
else {
    // Default action
}
```

Yes I realize this isn't the ugliest code but it seems less elegant to me over a standard switch statement and I find the casting tedious.  Especially since it requires you to write every type twice.  

What I want to say is "Given this type, execute this block of code."  So I decided to run with that this afternoon.  Lambdas will serve nicely for the block of code and using type inference will allow us to avoid writing every type out twice.  What I ended up with was a class called TypeSwitch with 3 main methods (see bottom of post for full code).

  * Do - Entry point where switching begins 
  * Case - Several overloads which take a generic type argument and an Action<T> to run for the object 
  * Default - Optional default action. 

I wrote a quick winforms app to test out the solution.  I dropped some random controls on a from and bound the MouseHover event for all of them to a single method.  I can now use the following code to print out different messages based on the type.

``` csharp
TypeSwitch.Do(
    sender,
    TypeSwitch.Case<Button>(() => textBox1.Text = "Hit a Button"),
    TypeSwitch.Case<CheckBox>(x => textBox1.Text = "Checkbox is " + x.Checked),
    TypeSwitch.Default(() => textBox1.Text = "Not sure what is hovered over"));
```

Notice that for check box I was able to access CheckBox properties in a strongly typed fashion.  The underlying case code will optionally pass the first argument to the lambda expression strongly typed to the value specified as the generic argument.

There are a couple of faults with this approach including Default being anywhere in the list but it was a fun experiment and works well.

TypeSwitch code.
    
``` csharp
static class TypeSwitch {
    public class CaseInfo {
        public bool IsDefault { get; set; }
        public Type Target { get; set; }
        public Action<object> Action { get; set; }
    }

    public static void Do(object source, params CaseInfo[] cases) {
        var type = source.GetType();
        foreach (var entry in cases) {
            if (entry.IsDefault || type == entry.Target) {
                entry.Action(source);
                break;
            }
        }
    }

    public static CaseInfo Case<T>(Action action) {
        return new CaseInfo() {
            Action = x => action(),
            Target = typeof(T)
        };
    }

    public static CaseInfo Case<T>(Action<T> action) {
        return new CaseInfo() {
            Action = (x) => action((T)x),
            Target = typeof(T)
        };
    }

    public static CaseInfo Default(Action action) {
        return new CaseInfo() {
            Action = x => action(),
            IsDefault = true
        };
    }
}
```


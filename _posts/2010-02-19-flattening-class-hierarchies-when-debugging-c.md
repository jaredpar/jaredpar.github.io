---
layout: post
---
One piece of feedback I heard in the MVP sessions this week is that debugging
deep class hierarchies in C# is painful. By default C# will only display the
fields and properties declared on a given type. To get to base class members
you must expand the base node. For large hierarchies this can take several
rounds of expansions to get to the desired value.

Take for instance the following class hierarchy

    
    
    class Animal {


        public string name;


        public Animal(string name) {


            this.name = name;


        }


    }


    


    class Dog : Animal {


        public string color;


        public Dog(string name, string color)


            : base(name) {


            this.color = color;


        }


    }


    


    class Mutt : Dog {


        public List<string> breeds;


        public Mutt(string name, string color, params string[] breeds)


            : base(name, color) {


            this.breeds = new List<string>(breeds);


        }


    }

When you are working with an instance of Mutt in the debugger, it takes 3
rounds of clicking to see what it's name is.

![image](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/Flattening
classhierarchieswhendebuggingC_A418/image_thumb.png)

The bigger hierarchy the more clicks that are needed to get the the value that
is desired. This can lead to a bit of frustration when you have significantly
deep object hierarchies.

Several MVP's asked for an option to flatten the hierarchies in a debugging
session so they could get at their data quicker. The bad news is this option
does not exist today and will not be present in Visual Studio 2010. The good
news though is that you can still get this behavior in Visual Studio today by
taking advantage of the existing debugging infrastructure.

In Visual Studio 2005 the debugging team added a set of attributes to the BCL
which allowed end users to customize their debugging experience. We can use
three of these attributes to create a flattened hierarchy for a given object.

  * [DebuggerTypeProxy](http://msdn.microsoft.com/en-us/library/system.diagnostics.debuggertypeproxyattribute.aspx) ' When expanding a value in the debugger instead of showing the children of the current value create an instance of this type and display it's children instead
  * [DebuggerBrowsable](http://msdn.microsoft.com/en-us/library/system.diagnostics.debuggerbrowsableattribute.aspx) ' Allows the developer to manipulate the display of a single field or property in a Type
  * [DebuggerDisplay](http://msdn.microsoft.com/en-us/library/system.diagnostics.debuggerdisplayattribute.aspx) ' Allows the developer to control what is displayed in the Name, Value and Type columns for instances of a Type

The basic strategy for flattening a hierarchy is to do the following in our
type proxy.

  1. Create a new type to hold the Tuple of name, value and type for every member. Lets call it Member
  2. Add a DebuggerDisplay attribute to Member to make it's display emulate how an equivalent member would normally be displayed in the debugger
  3. Use reflection to grab all of the fields and properties defined for a value wrapping them in Member instances
  4. Expose all of the Members for a value through a property as a strongly typed array
  5. Attribute the property with DebuggerBrowsable.RootHidden. This has the effect of hiding the wrapping property and instead promoting all of it's children in it's place which effectively inlines all of the Member instances as children of the proxy

The result is a type proxy which will display all of the members of an object
inline. Here is the full code sample



    
    
    internal sealed class FlattenHierarchyProxy {


    


        [DebuggerDisplay("{Value}", Name = "{Name,nq}", Type = "{Type.ToString(),nq}")]


        internal struct Member {


            internal string Name;


            internal object Value;


            internal Type Type;


            internal Member(string name, object value, Type type) {


                Name = name;


                Value = value;


                Type = type;


            }


        }


    


        [DebuggerBrowsable(DebuggerBrowsableState.Never)]


        private readonly object _target;


        [DebuggerBrowsable(DebuggerBrowsableState.Never)]


        private Member[] _memberList;


    


        [DebuggerBrowsable(DebuggerBrowsableState.RootHidden)]


        internal Member[] Items {


            get {


                if (_memberList == null) {


                    _memberList = BuildMemberList().ToArray();


                }


                return _memberList;


            }


        }


    


        public FlattenHierarchyProxy(object target) {


            _target = target;


        }


    


        private List<Member> BuildMemberList() {


            var list = new List<Member>();


            if ( _target == null ) {


                return list;


            }


    


            var flags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance;


            var type = _target.GetType();


            foreach (var field in type.GetFields(flags)) {


                var value = field.GetValue(_target);


                list.Add(new Member(field.Name, value, field.FieldType));


            }


    


            foreach (var prop in type.GetProperties(flags)) {


                object value = null;


                try {


                    value = prop.GetValue(_target, null);


                }


                catch (Exception ex) {


                    value = ex;


                }


                list.Add(new Member(prop.Name, value, prop.PropertyType));


            }


    


            return list;


        }


    }

The last step is to attribute the root of our type hierarchy with this type
proxy.

    
    
    [DebuggerTypeProxy(typeof(FlattenHierarchyProxy))]


    class Animal {

Now when when debugging instances which derive from Animal developers will see
a flattened hierarchy of values.

![image](http://blogs.msdn.com/blogfiles/jaredpar/WindowsLiveWriter/Flattening
classhierarchieswhendebuggingC_A418/image_thumb_1.png)


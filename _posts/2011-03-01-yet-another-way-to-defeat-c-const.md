---
layout: post
title: Yet Another Way to Defeat C++ const
---
One of my favorite C++ features, and one I feel is terribly underutilized in many code bases, is the **const** mechanism. It's a great mechanism for defining dual roles for the same object type: a mutable and (ideally) non-mutable one. But as useful as **const** is it's also very easy to circumvent and I'm always interested in learning new ways to do so.

While navigating through a stackoverflow [question](http://stackoverflow.com/questions/5148656/c-how-can-we-call-delete-this-in-a-const-member-function) yesterday I came across yet another way to defeat C++ **const**. In C++ it's perfectly legal to call delete on a **const** value. This code path though transitions from a **const** * to a type to a **non-const** pointer by means of **'this'**in the destructor code.  From there it's possible to call any other mutable method in the type and bypass the original **const** without any nasty casts. For example

    
``` c++
class Example {
public:
    ~Example() {
        MutableMethod();
    }

    void MutableMethod() {
        cout << "Example::MutableMethod()" << endl;
    }

    void ConstMethod() const {
        delete this;
    }
};
```

With this type I can easily defeat **const **restrictions by simply deleting it

    
``` c++
const Example* pLocal = new Example();
pLocal->ConstMethod();
```

Granted this is not terribly useful when considering the **const **of the immediate type. It's being deleted after all so messing around in it is unlikely to cause too much of a fuss. However it can be interesting when considering the access of nested members within the type which may live longer than the container being deleted.


---
layout: post
---
Recently I ran into a situation on a personal project where I needed a hashtable like structure for a set of WeakReference values. When poking around for an existing implementation I saw found several versions which were very thin, type safe wrapper around a Dictionary<TKey,WeakReference> (usually the class even implements IDictionary<TKey,TValue> directly). While this produces a type safe API it fails to take into account the different nature of a WeakReference. Because a WeakReference is constantly being collected without explicit user action it alters the types of operations that be performed on them. Failing to take this into account produced APIs which lead users to write incorrect code.

Finding no suitable implementation I set off to build my own. It took several iterations and I thought the result and process would be fun to share the design experience as a blog post.

Let start with the basics. At a high level the API should appear to the user as a type safe Dictionary<TKey,TValue>. Under the hood all values will be stored in an instance of WeakReference in order to enable collection. But this is an implementation detail and should not be visible to the user.'? The user should only see type safe keys and values.

A standard Hashtable works on the concept of a key/value pair. A value is associated with a particular key in the table and at any time, the value can be retrieved from the hashtable with the specified key. A key can be determined to be valid simply by ascertaining it's presence in the underlying table. The value is irrelevant, it's mere presence makes it valid.

A weak hashtable will work on the same concept but have a much different implementation. Keys are only valid if they point to an actual value. Since the value in the hashtable is a WeakReference the mere presence of the key does not determine it's validity. Only the presence of the key and the value contained within the weak reference determines the validity of a key.

This seems like an obvious assumption but it has a dramatic impact on the type of API a weak hashtable can have. Lets take a simple property such as Count for an example of why this is important. Count on a hashtable is used to determine the number of valid key/value pairs in the table. On a normal hashtable, this count is simply incremented and decremented with the corresponding Add and Remove API's. With a weak hashtable, any given run of the garbage collector can affect the count of key/value pairs by collecting a value. This means a simple counter cannot be used to keep track of the valid key/value pairs.

In order to get the actual Count every singe value must be accessed an verified that it is still alive. What's even worse is that once a value is determined to exist, it must be stored for the duration of the Count method.  Otherwise a GC could occur in the middle of the loop and collect Values that were marked as still alive.

This is what Count would need to look like '

{% highlight csharp %}
public class WeakHashtable<TKey,TValue> {
    private Dictionary<TKey, WeakReference> _map;
    public int Count {
        get {
            var list = _map.Values
                .Select(x => x.Target)
                .Where(x => x != null)
                .ToList();
            return list.Count;
        }
    }
}
{% endhighlight %}

Count transformed from a simple O(1) return of an internal counter to a O(N) method which allocates memory. Worse yet, the return value is practically useless. As soon as the value is returned it cannot be considered to be valid. A GC could kick in and invalidate half the table. Count would in fact be giving the user information about the object in the past.

In some ways, this problem is similar to issues encountered with multi-threaded applications. In between every line of your code there is another operation, in this case the GC, which can alter the state of your structure.

The only API's that can ask questions about a value and still have a reasonable use by the user must return the value with the call. Returning the value will, at least temporarily, provide a GC root and prevent the object from being collected. It gives the user a chance to use the value before it's taken out from under them.

A good API comparison here are operations such as Contains and TryGetValue.  Contains holds no value to the user because as soon as the call returns the GC can collect the value. TryGetValue on the other hand returns the value in question thus locking it in memory and preventing a collection.

When designing the API for a weak hashtable I tried to keep it simple and stick to these ideas. I started with the [IDictionary<TKey,TValue>](http://msdn.microsoft.com/en-us/library/s4ys34ea.aspx) interface and removed the methods which hold no value for the end user due to GC limitations. In the end I was left with only the following.

  * void Add(TKey key, TValue value) 
  * bool Remove(TKey key) 
  * void Clear() 
  * bool TryGetValue(TKey key, out TValue value) 
  * List<TValue> Values { get; } 

I also added the following methods

  * List<Tuple<TKey,TValue>> Pairs?? { get; } 
  * Put(TKey key, TValue value) 
  * Option<TValue> TryGetValue(TKey key); 

The Values property returns a List<TValue> implementation instead of IEnumerable<TValue>?? In order to guarantee the values remain in existence they must be rooted in some structure. The easy choice is a List<TValue>. Since a List<TValue> must be created anyways, why return a less accessible interface such as IEnumerable<TValue>?

At first I did consider a design where Values returned IEnumerable. It is fairly simple to implement with a C# iterator.

{% highlight csharp %}
public IEnumerable<TValue> Values {
    get {
        foreach (var weakRef in _map.Values) {
            var obj = weakRef.Target;
            if (obj != null) {
                yield return (TValue)obj;
            }
        }
    }
}
{% endhighlight %}

The problem though is that anything more than a simple .ForEach() over the IEnumerable may behave unexpectedly. Consecutive calls to GetEnumerator can produce different enumerations with no explicit user alteration of the table.  I've seen several APIs which (rightly or wrongly) make this assumption. Given the user is not explicitly modifying the collection, it is not a necessarily bad assumption to make. However it would not work for a collection of this type.

I intentionally left off Keys here. Keys are only valid when they have a live value in the table. Unless the Value is returned with Key this cannot be guaranteed. The Pairs property serves this role.

This post went a bit longer than I originally intended. I also wanted to discuss how compaction of the table should work in a weak hashtable. I'll save that for next time.

Here is the implementation of the dictionary without any compaction support.

{% highlight csharp %}
public sealed class WeakDictionary<TKey, TValue> {
    private Dictionary<TKey, WeakReference> m_map;

    public List<Tuple<TKey, TValue>> Pairs {
        get {
            return m_map
                    .Select(p => Tuple.Create(p.Key, p.Value.Target))
                    .Where(t => t.Second != null)
                    .Select(t => Tuple.Create(t.First, (TValue)t.Second))
                    .ToList();
        }
    }

    public List<TValue> Values {
        get { return Pairs.Select(x => x.Second).ToList(); }
    }

    public WeakDictionary()
        : this(EqualityComparer<TKey>.Default) {
    }

    public WeakDictionary(IEqualityComparer<TKey> comparer) {
        m_map = new Dictionary<TKey, WeakReference>(comparer);
    }

    public void Add(TKey key, TValue value) {
        m_map.Add(key, new WeakReference(value));
    }

    public void Put(TKey key, TValue value) {
        m_map[key] = new WeakReference(value);
    }

    public bool Remove(TKey key) {
        return m_map.Remove(key);
    }

    public Option<TValue> TryGetValue(TKey key) {
        WeakReference weakRef;
        if (!m_map.TryGetValue(key, out weakRef)) {
            return Option.Empty;
        }

        var target = weakRef.Target;
        if (target == null) {
            return Option.Empty;
        }

        return (TValue)target;
    }

    public bool TryGetValue(TKey key, out TValue value) {
        var option = TryGetValue(key);
        value = option.ValueOrDefault;
        return option.HasValue;
    }
}
{% endhighlight %}


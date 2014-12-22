---
layout: post
---
At home I code a lot of singleton classes.  Most of this code is boilerplate code that I just write over and over again.  Originally I thought that generics would solve this problem.  I planned to write a generic singelton of the following form. 

``` csharp
public class Singleton<T,K> : K
{
   public static T Instance 
   {
      // ... Singleton code 
   }
}

public class MyFactory : Singleton<MyFactory,MyBaseFactoryClass>
{
}
```

Unfortunately that doesn't work because generics in .NET do not support inheritance of that kind (AFAIK).  This forced me to find a different route.  I decided to code a generic singleton class that operated on static methods.  I wanted to get the behavior below. 

``` csharp
public class MyFactory
{
   public static MyFactory Instance 
   { 
      get 
      { 
         return Singleton<MyFactory>.GetInstance(); 
      } 
   }
}
```

This still didn't solve my problems because this requires that MyFactory have a public constructor.  I had to settle for this instead. 

``` csharp
public class MyFactory
{
   public static MyFactory Instance 
   { 
      get 
      { 
         return Singleton<MyFactory>.GetInstance(delegate() { return new MyFactory(); } ); 
      } 
   }
}
```

This makes it very simple to create per process singleton classes.  It's not quite as easy as my original idea but it gets the job done and removes a lot of redundant code.  Here's the code that I'm using for my Singleton<T> class. 

``` csharp
public static class Singleton<T>
{
   public delegate T SingletonCreation();

   private static T _instance;

   public static T GetInstance(SingletonCreation del)
   {
      if (_instance == null)
      {
         lock (typeof(Singleton<T>))
         {
            if (_instance == null)
            {
               T temp = del();
               System.Threading.Thread.MemoryBarrier();
               _instance = temp;
            }
         }
      }
      return _instance;
   }
}
```

For more information on singletons in .NET check out this great entry by Brad Abrams http://blogs.msdn.com/brada/archive/2004/05/12/130935.aspx

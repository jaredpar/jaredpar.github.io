---
layout: post
---
Writing a proper serialization mechanism is ofter very difficult.  The problem is most people don't realize this because it just works in their application and .Net makes it very easy to do.  A lot of the problem is not understanding what factors you need to consider when writing a serializer.

Failures with serialization can be classified in two ways

1. Critical - Deserialization is impossible.  Typically resulting in a runtime exception or fata error
2. Incorrect - Deserialization succeeds but the underlying data is incorrect in some fashion

For this post I use the term "box" describes a place where all the factors which can interfere with proper serialization differ.  Below is a list of all of the factors I know of that can affect serialization.  And by affect I mean that serializing data in one "box" and deserializing it in another "box" could have an affect on the data.

1. Process - There are types of data which are only valid within the process where they are created.  For instance when you open a file in Windows, you are given a handle.  The handle is only valid for the process where the file was opened, passing it to another process by value will cause an error in the target process.  Or worse the handle will be valid in the target process but will not point to the same file. 
2. Computers - This problem is a superset of the process problem.  In addition to the problems of a process you have to deal with setup.  For instance binary serialization in .Net takes an inherit dependency on assemblies at a specific version[1].  If the target computer does not have these assemblies then deserialization will fail.
3. TimeZone / Where - If you embed time in your data as a string and serialize/deserialize in different time zones you will encounter an "Incorrect" deserialization failure.
4. Thread - There are particular types of data that are only valid within a specific thread (thread local storage, COM pointers).  Depending on the type of data it can cause varying failures in an application.  One good example of this are COM pointers.  COM has strict marshalling rules with respect to threads[2].  Passing a COM interface pointer between threads without calling into appropriate API (CoMarshalInterThreadInterfaceInStream , CoGetInterfaceAndReleaseStream). 
5. Application Domain - Application Domains in .Net are essentially mini-processes.  While it's probably valid to pass a file handle between application domains, it's not always valid to pass managed protected resources between two domains.  Every application domain in a .Net process can have different security permissions and hence it's possible to pass references to in-accessible resources to other application domains.
6. BigEndian / Little Endian - If you're doing custom serialization to bytes you also need to be concerned with the endian-ness of the machine you're working on.  It's possible (albeit hard) to get into this problem and most people won't ever have to deal with it for a managed application.  I don't know of a good way to hit this in managed code but it's definately a problem for cross platform application and unmanaged code.

Most of the problems I've seen with respect to serialization is because people embed a "box" sensitive resource in their serialization data but don't realize it.  When desigining serialization for your data you need to consider all of the factors above which affect your application.

The good news is most applications don't have to consider all of the above factors into their application.  Below is a breakdown of some common category applications and the list of factors they have to consider.  

1. MyApp Serializers - The data is serialized for my application and my application only.  It's a hobby app or a small office app. These are the easiest because they usually only have to take into account factor #1.  They don't care about application domains, computer->computer communication and the like.  They have some data they'd merely like to preserve between sessions in a file somewhere for this particular user.
2. Product Serializer - The is a for sale global product and reliability is key.  But once again the data is only serialized by and for my application.  They are a bit harder because they are expected to work in more situations.  They may have to consider a wider range of scenarios including threads and application domains. 
3. Cooperative App - This app serializes data for use in other "boxes".  These are the hardest to write because they often have to 

[1] There are ways to relax these dependencies but at the end of the day some version of the assembly must be on the machine.

[2] Lookup COM Apartments for more information.


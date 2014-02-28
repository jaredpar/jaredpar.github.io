---
layout: post
---
Earlier this week I started writing a function which needed to represent three
states in the return value, two of which had an associated value.  In my mind
I immediately came to the following solution

    
    
    type BuildAction =


        | Reset


        | LinkOneWithNext of Statement


        | LinkManyWithNext of Statement seq

A discriminated union is perfectly suited for representing this type of
scenario.  Unfortunately for me I was coding in C++ and not F# so I shifted
gears and started on a different solution.  But I quickly grew frustrated with
new solution and decided to backtrack.  A discriminated union is just too
ideal for this scenario so why not spend fifteen minutes and see how far I
could get in defining a discriminated union structure in C++.

Of course a full discriminated union in the style of F# is not possible
because C++ lacks language support for pattern matching.  But I was willing to
live with that and other limitations as long as I could get many of the other
benefits I find with discriminated unions.  In particular

  * Declarative Syntax 
  * Typed value access without the need to cast 
  * Allow mixing of flag only and flags with values 
  * Customized naming of entries (no tuple style First, Second, etc ???)
  * Instances are read only 

After a bit of tinkering I came up with a solution (full source at end of
post) which allows for the following declaration syntax

    
    
    DECLARE_DISCRIMINATED_UNION(BuildAction)


        DISCRIMINATED_UNION_FLAG(BuildAction, Reset)


        DISCRIMINATED_UNION_VALUE(BuildAction, LinkOneWithNext, Statement)


        DISCRIMINATED_UNION_VALUE(BuildAction, LinkManyWithNext, vector<Statement>)


    END_DISCRIMINATED_UNION()

Each declared entry in the union is provided the following methods.

  * A static factory method for creating values: CreateLinkOneWithNext
  * A method to test to see if an instance is the value type: IsLinkOneWithNext
  * A method to get the value associated with the associated value: GetLinkOneWithNext



    
    
    auto action = BuildAction::CreateLinkOneWithNext(statement);


    


    if (action.IsLinkOneWithNext()) {


        Method(action.GetLinkOneWithNext());


    }

It's certainly far from perfect.  But it did give me the tools to implement
the solution in the way I inherently thought about it and freed me to spend my
thinking time on other problems.

**EDIT**

A couple of people asked why I didn't use boost::variant for this solution?
Ideally this is the approach I would've taken.  But for this particular
scenario boost was unfortunately not an option (no weird management issues,
just a boring production environment one).  

Additionally the spirit of this post and experiment was just having a bit of
fun and sharing the results (even though it does contain a few pieces of evil
code).

DiscriminatedUnion.h

    
    
    //----------------------------------------------------------------------------


    //


    // Discriminated Union in C++.


    //


    //----------------------------------------------------------------------------


    #ifdef DECLARE_DISCRIMINATED_UNION


    #undef DECLARE_DISCRIMINATED_UNION


    #endif


    


    #ifdef END_DISCRIMINATED_UNION


    #undef END_DISCRIMINATED_UNION


    #endif


    


    #ifdef DISCRIMINATED_UNION_VALUE


    #undef DISCRIMINATED_UNION_VALUE


    #endif


    


    #ifdef DISCRIMINATED_UNION_POINTER


    #undef DISCRIMINATED_UNION_POINTER


    #endif


    


    #ifdef DISCRIMINATED_UNION_ALLOW_NONE


    #undef DISCRIMINATED_UNION_ALLOW_NONE


    #endif


    


    #ifdef DISCRIMINATED_UNION_GET_KIND


    #undef DISCRIMINATED_UNION_GET_KIND


    #endif


    


    #define DECLARE_DISCRIMINATED_UNION(name)       \


        struct name {                               \


        private:                                    \


            name() {}                               \


            unsigned __int32 m_kind;                \


        public:


    


    #define DECLARE_DISCRIMINATED_UNION_WITH_NONE(name)         \


        struct name {                                           \


        private:                                                \


            unsigned __int32 m_kind;                            \


        public:                                                 \


            name() : m_kind(__LINE__) {}                        \


            bool IsNone() const {return m_kind == __LINE__;}


    


    #define DISCRIMINATED_UNION_VALUE(unionName, entryName, entryType)                                          \


            static unionName Create##entryName(const entryType& value) {                                        \


                unionName unionValue;                                                                           \


                unionValue.m_kind = __LINE__;                                                                   \


                unionValue.m_##entryName = value;                                                               \


                return unionValue;  }                                                                           \


            bool Is##entryName() const { return m_kind == __LINE__;}                                            \


            const entryType& Get##entryName() const { ASSERT(m_kind == __LINE__); return m_##entryName; }       \


            entryType Get##entryName() { ASSERT(m_kind == __LINE__); return m_##entryName; }                    \


        private:                                                                                                \


            entryType m_##entryName;                                                                            \


        public:


    


    #define DISCRIMINATED_UNION_POINTER(unionName, entryName, entryType)                                        \


            static unionName Create##entryName(entryType* value) {                                              \


                unionName unionValue;                                                                           \


                unionValue.m_kind = __LINE__;                                                                   \


                unionValue.m_##entryName = value;                                                               \


                return unionValue;  }                                                                           \


            bool Is##entryName() const { return m_kind == __LINE__;}                                            \


            entryType* Get##entryName() const { ASSERT(m_kind == __LINE__); return m_##entryName; }             \


            entryType* Get##entryName() { ASSERT(m_kind == __LINE__); return m_##entryName; }                   \


        private:                                                                                                \


            entryType* m_##entryName;                                                                           \


        public:


    


    #define DISCRIMINATED_UNION_FLAG(unionName, entryName)                                                      \


            static unionName Create##entryName() {                                                              \


                unionName unionValue;                                                                           \


                unionValue.m_kind = __LINE__;                                                                   \


                return unionValue;  }                                                                           \


            bool Is##entryName() const { return m_kind == __LINE__;}                                            


    


    #define DISCRIMINATED_UNION_GET_KIND() unsigned __int32 GetKind() const { return m_kind; }


    


    #define END_DISCRIMINATED_UNION() };


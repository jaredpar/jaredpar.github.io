
12.1.1.3

12.3.2.1
When a method is called, an unmanaged pointer (type native unsigned int or *) is permitted to match a parameter that requires a managed pointer (type &).  The reverse, however, is not permitted since it would allow a managed pointer to be “lost” by the memory manager. 

Instructions that create pointers which are guaranteed not to point into the memory manager’s heaps (e.g., ldloca, ldarga, and ldsflda) produce transient pointers (type *) that can be used wherever a managed pointer (type &) or unmanaged pointer (type native unsigned int) is expected

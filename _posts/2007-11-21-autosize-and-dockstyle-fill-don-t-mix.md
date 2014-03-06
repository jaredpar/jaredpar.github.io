---
layout: post
---
The title of this post essentially says it all. AutoSize and DockStyle.Fill don't mix well together. Both properties exist to describe the size relationship relative to the rest of the control but they do so in conflicting ways.

AutoSize is a property describing the size of a control relative to it's contents. Setting this to True will generally cause a control to resize itself so that it takes up only enough room to display it's contents.  

DockStyle.Fill is a property describing the size of a control relative to the size of it's container. A control will resize to fit all of the empty space in it's parent container with this property set.

In effect these properties represent opposite ways of describing size. Most controls will prevent you from setting conflicting settings in the designer.  However it's difficult to prevent you from setting conflicting settings between a container and it's contents.

For instance, one combination is the following. This may seem a little odd at first. It commonly happens when you are trying to embed a non-autosizing control inside a Container that supports AutoSize. For instance if you are trying to place a TextBox inside of a FlowLayoutPanel 

* Container
    * AutoSize = true
    * AutoSizeMode = GrowAndShrink
* Containee
    * Dock = DockStyle.Fill

If you try this code it will often cause the Container Control to shrink to nothing. Why' In affect both controls are asking each other how big they should be and with no one having the deciding factor they agree on ...  nothing.

Instead for this scenario you should leave the Containee to DockStyle.None and manually set the size.


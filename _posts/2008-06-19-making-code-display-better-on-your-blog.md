---
layout: post
---
My blogging tool is Windows Live Writer and I use the "Insert From Visual
Studio" plug-in to get pretty looking code into my postings. The generated
code uses the <pre> tag for formatting the elements.

Unfortunately my blog provider doesn't always render this properly and will
clip text that is too long. Ideally I would like to either

  1. Wrap code that overflows the page 
  2. Put up a localized scroll bar for the code snippet 

Luckily the plug-in puts the outer most <pre> tag into it's own CSS class:
code. This makes the problem easy with a CSS override.

pre.code {  
?? overflow : auto;  
}


---
layout: post
---
While investigating a recent bug I found about an interesting return for GetParamForMethodIndex.  On a perfectly verifiable assembly, a call to GetParamForMethodIndex was returning a failure code. After some searching I found the return code was CLDB_E_RECORD_NOTFOUND. I was surprised at first because it's a verifiable assembly so how could the record for a parameter I knew existed not be there?

It turns out this is legal.  GetParamForMethodIndex returns a mdParamDef token by which you can query for information about a parameter with GetParamProps.  This will return the following information about a parameter.

  * Name of the parameter
  * Attributes about the param (ByRef, Marshal, etc ...)
  * Default value

In this particular case the assembly was generated without a parameter name.  As it also had none of the information the parameter row was omitted from the metadata.  The reason is adding an empty row takes up space and provides no data.

Note you can't reproduce this behavior with ILASM.exe.  If you omit a parameter name, ILASM.exe will add one for you and hence generate a parameter row.


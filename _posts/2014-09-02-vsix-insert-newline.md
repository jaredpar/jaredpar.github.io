---
layout: post
title: Correctly inserting a new line in a VSIX
tags: vsix
---
To split a line in an `ITextBuffer` the developer simply needs to insert a recognized new line text into the existing line.  Many VSIX extensions just default to `Environment.NewLine` for this task 

``` csharp
_textBuffer.Insert(splitPosition, Environment.NewLine);
```

This is problematic because this is simply not the only possible new line text.  The editor actually recognizes 6 varieties: `'\r'`, `'\n'`, `"\r\n"`, `'\u2028'`, `'\u2029'` and `'0x85'`.  The other 5 sequences are more likely to come about on cross platform extensions.  New files tend to end up with the preferred line ending of the host operating system (Windows is `"\r\n"` and OSX is `'\n'`).  Hence cross platform extensions tend to end up with files that have a variety of endings.  

Extensions which default to `Environment.NewLine` will work great right up until a cross platform developer starts using it.  Then it will end up causing files to have multiple line ending sequences which quickly leads to all manner of tooling warniings: including Visual Studio popping up a modal dialog (yuck!).  

To avoid this extensions should be careful to preserve the existing line ending text for a file.  But where can an extension discover the correct line ending?  The [`GetNewLineCharacter`](http://msdn.microsoft.com/en-us/library/microsoft.visualstudio.text.editor.optionsextensionmethods.defaultoptionextensions.getnewlinecharacter.aspx) method looks attractive at a glance but is unacceptable for the following reasons:

1. It presumes that a buffer has a single new line text sequence for the entire buffer.  This is generally true for a physical file but not true for an arbitrary `ITextBuffer` which can be a [projection of multiple files](http://msdn.microsoft.com/en-us/library/microsoft.visualstudio.text.projection.aspx).  
2. Even in files which exclusively have a non-windows line ending it will still have the value `"\r\n"`. 

Instead the best way to choose the text for a new line is to just use the line break text from the line being split.  Or in the case of the last line of the file, the line break text of the line above it.  For example:

``` csharp
static string GetNewLineText(SnapshotPoint point)
{
  var line = point.GetContainingLine();

  if (line.LineBreakLength > 0)
  {
    return line.GetLineBreakText();
  }
  else if (line.LineNumber - 1 >= 0)
  {
    // If this is the last line then there is no line break, use the line above 
    var lineAbove = line.Snapshot.GetLineFromLineNumber(line.LineNumber - 1);
    return lineAbove.GetLineBreakText();
  }
  else
  {
    // Buffer only hase a single line, use the default new line sequence 
    return Environment.NewLine;
  }
}
```

Use this method instead of defaulting to `Environment.NewLine`, your cross platform customers will appreciate it.  


---
layout: post
title: Correctly inserting a new line into an ITextBuffer
tags: vsix
---
VSIX extensions which manipulate text in the editor need to be careful use the correct line break sequence when inserting new lines.  The standard windows line ending is `'\r\n'` 

VSIX extensions which manipulate text in the editor need to be careful when inserting new lines.  Most Windows developers tend to think of new lines as `'\r\n'`.  This 


when inserting new lines.  Most extensions split line by inserting `Environment.NewLine` at the split point.  Given that Windows and Visual Studio default to `'\r\n' for line breaks this will work for a good portion of developers (those who work only on Windows).  

This solution often causes frustration to developers who do cross platform development.  Their files are more likely to have a different line ending as a result of development on other platforms (OSX prefers `'\n'`).  When a VSIX extension suddenly adds a stray `'\r\n'` into the file it leads warnings from all sorts of tools: including model dialogs in Visual Studio (yuck).  




Visual Studio actually recognizes 6 different line ending sequences: `'\r', '\n', "\r\n", '\u2028', '\u2029' and '0x85'.  



This tends to break developers that do cross platform development as they are more likely to have other line endings as a result of editing on other platforms.






The Windows and Visual Studio defaults push most code files to use the standard `"\r\n"` ending.  This leads a lot of extensions to lazily use `Environment.NewLine` when splitting lines.  This works gert w



Eventually the extension is picked up by a developer doing cross platform work and it breaks 


The Visual Studio Editor actually recognizes 5 different character sequences as new lines: `'\r', '\n', "\r\n", '\u2028', '\u2029' and '0x85'.  

- `'\r'`

``` csharp
using Microsoft.VisualStudio.Text.Editor.OptionsExtensionMethods;

...

static string GetNewLineText(SnapshotPoint point, IEditorOptions editorOptions)
{
  if (editorOptions.GetReplicateNewLineCharacter())
  {
    var line = point.GetContainingLine();

    if (line.LineBreakLength > 0)
    {
      return line.GetLineBreakText();
    }
    else if (line.LineNumber - 1 >= 0)
    {
      // If this is the last line there is no line break, use the line above 
      var lineAbove = line.Snapshot.GetLineFromLineNumber(line.LineNumber - 1);
      return lineAbove.GetLineBreakText();
    }
  }

  // Either we aren't replicating new lines or the buffer only 
  // has a single line.  Use the default new line character
  return editorOptions.GetNewLineCharacter();
}
```

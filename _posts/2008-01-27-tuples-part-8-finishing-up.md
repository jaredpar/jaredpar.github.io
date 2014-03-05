---
layout: post
---
There are only a few missing features from our tuple implementation.  Mainly FxCop compliance, debugging support and test case code.  The actual functional work is complete. 

The one issue with FxCop compliance is the chosen names.  Namely using A,B etc.  FxCop, rightly, believes names should have more value.  Accordingly, calling the generic argument corresponding to A, TA also causes the same issue.  This is a design decision made from the begining.  I don't believe changing the name to ValueA adds any more value than simply A.  Therefore the warning for this will simply be suppressed.

Additionally FxCop doesn't like types with more than 3 generic parameters.  This is also a design decision intentionally done and there is no avoiding it.  It will be suppressed as well. 

For debugging support a simple DebuggerDisplay attribute will be used.  It will display the current value of all of the tuple values. 

Here is the latest version of the full script which includes all of the new information.  With the exception of a few small tweaks this is just the combination of the individual parts specified throughout these postings.


{% highlight powershell %}
{% raw %}
param ( [int]$tupleCount = 5, 
        [string]$namespace = "Tuples" )

$script:scriptPath = split-path -parent $MyInvocation.MyCommand.Definition 
$script:lowerList = 0..25 | %{ [char]([int][char]'a'+$_) } 
$script:upperList = 0..25 | %{ [char]([int][char]'A'+$_) } 
$script:valueList = "1","42",'"bar"', '"foo"', 'true'

function script:Gen-FxCop 
{ 
    param ( [int]$code )

    switch ( $code ) 
    { 
        1704 { '[SuppressMessage("Microsoft.Naming", "CA1704")]'; break } 
        1005 { '[SuppressMessage("Microsoft.Design", "CA1005")]'; break } 
        default: {$(throw "Invalid")} 
    } 
}

function script:Gen-Display 
{ 
    param ( [int]$count ) 
    $OFS = ", " 
    $p = [string](0..($count-1) | %{ "{0}={{{0}}}" -f $upperList[$_] }) 
    '[DebuggerDisplay("{0}")]' -f $p 
}

function script:Gen-Property 
{ 
    param ( [int] $index  = $(throw "Need an index"), [bool]$mutable = $false)

    if (-not $mutable ) 
    { 
@" 
    private readonly T{0} m_{1}; 
    $(Gen-FxCop 1704) 
    public T{0} {0} {{ get {{ return m_{1}; }} }}

"@ -f $upperList[$index],$lowerList[$index] 
    } 
    else 
    { 
@" 
    private T{0} m_{1}; 
    $(Gen-FxCop 1704) 
    public T{0} {0} {{ get {{ return m_{1}; }} set {{ m_{1} = value; }} }}

"@ -f $upperList[$index],$lowerList[$index] 
    } 
}

function script:Gen-Constructor 
{ 
    param ( [int] $count = $(throw "Need a count"), [string]$className ) 
    $OFS = ',' 
    $list = [string](0..$($count-1) | %{ "T{0} value{0}" -f $upperList[$_]}) 
    "public $className($list) {" 
    0..($count-1) | %{ "m_{0} = value{1};" -f $lowerList[$_],$upperList[$_] } 
    "}" 
}

function script:Gen-InferenceConstructor 
{ 
    param ( [int] $count = $(throw "Need a count"), [string]$name ) 
    $OFS = ',' 
    $gen = "<" + [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"     
    $list = [string](0..$($count-1) | %{ "T{0} value{0}" -f $upperList[$_] }) 
    $argList = [string](0..$($count-1) | %{ "value{0}" -f $upperList[$_] }) 
    "public static partial class $name {" 
    Gen-FxCop 1704 
    "public static $name$gen Create$gen($list) { return new $name$gen($argList); } " 
    "}" 
}

function script:Gen-Equals 
{ 
    param ( [int] $count = $(throw "Need a count"), [string]$name ) 
    $OFS = ',' 
    $gen = "<" + [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"     
    "public override bool Equals(object obj) { " 
    "return Equals(obj as $name$gen); }" 
    "public bool Equals($name$gen other) {" 
    "if ( Object.ReferenceEquals(other,null) ) { return false; }" 
    "if (" 
    $OFS = "&&" 
    [string](0..($count-1) | %{"EqualityComparer<T{0}>.Default.Equals(m_{1},other.m_{1})" -f $upperList[$_],$lowerList[$_] }) 
    ") { return true; }" 
    "return false;" 
    "}" 
}

function script:Gen-GetHashCode 
{ 
    param ( [int] $count = $(throw "Need a count") ) 
    "public override int GetHashCode() {" 
    "int code = 0;" 
    0..($count-1) | %{ "code += EqualityComparer<T{0}>.Default.GetHashCode(m_{1});" -f $upperList[$_],$lowerList[$_] } 
    "return code;" 
    "}" 
}

function script:Gen-ITuple 
{ 
    param ( [int] $count = $(throw "Need a count") ) 
    $OFS = ',' 
    $gen = "<" + [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"     
    $base = "" 
    if ( $count -ne 1 ) 
    { 
        $baseGen = "<" + [string](0..($count-2) | %{ "T"+$upperList[$_] }) + ">"     
        $base = ": ITuple$baseGen" 
    } 
    else 
    { 
        $base = ": ITuple" 
    } 
    Gen-FxCop 1704 
    if ( $count -gt 2 ) { Gen-FxCop 1005 } 
    "public interface ITuple$gen $base {" 
    Gen-FxCop 1704 
    "T{0} {0} {{ get; }}" -f $upperList[$count-1]  
    "}" 
}

function script:Gen-TupleAccess 
{ 
    param ( [int] $count = $(throw "Need a count"), [bool]$mutable ) 
    "public int Count { get { return $count; } }" 
    "public object this[int index] { get { switch (index){ " 
    0..($count-1) | %{ "case $($_): return m_$($lowerList[$_]);" } 
    "default: throw new InvalidOperationException(""Bad Index"");" 
    "} }"

    if ( $mutable ) 
    { 
        "set { switch (index) {" 
        0..($count-1) | %{ "case $($_): m_$($lowerList[$_]) = (T$($upperList[$_]))value; break;" } 
        "default: throw new InvalidOperationException(""Bad Index"");" 
        "} } " 
    } 
    "}" 
}

function script:Gen-OpEquals 
{ 
    param ( [int] $count = $(throw "Need a count"), [string]$name ) 
    $OFS = ',' 
    $gen = "<" + [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"     
    "public static bool operator==($name$gen left, $name$gen right) {" 
    "return EqualityComparer<$name$gen>.Default.Equals(left,right); }" 
    "public static bool operator!=($name$gen left, $name$gen right) {" 
    "return !EqualityComparer<$name$gen>.Default.Equals(left,right); }" 
}

function script:Gen-CompareTo 
{ 
    param ( [int] $count = $(throw "Need a count"), [string]$name ) 
    $OFS = ',' 
    $gen = "<" + [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"     
    "public int CompareTo(object obj) {" 
    "return CompareTo(obj as $name$gen); }" 
    "public int CompareTo($name$gen other) {" 
    "if ( Object.ReferenceEquals(other,null) ) { return 1; }" 
    "int code;" 
    0..($count-1) | 
        %{ "code = Comparer<T{0}>.Default.Compare(m_{1},other.m_{1}); if (code != 0) {{ return code; }}" -f $upperList[$_],$lowerList[$_] } 
    "return 0; }" 
    "public static bool operator>($name$gen left, $name$gen right) { " 
    "return Comparer<$name$gen>.Default.Compare(left,right) > 0; }" 
    "public static bool operator<($name$gen left, $name$gen right) { " 
    "return Comparer<$name$gen>.Default.Compare(left,right) < 0; }" 
}

function script:Get-Tuple 
{ 
    param ( [int] $count, [bool]$mutable = $false ) 
    $OFS = ',' 
    $gen = "<" + [string](0..($count-1) | %{ "T"+$upperList[$_] }) + ">"     
    Gen-FxCop 1704 
    Gen-Display $count 
    if ( $count -gt 2 ) { Gen-FxCop 1005 } 
    $name = "{0}Tuple" -f (Get-Ternary $mutable "Mutable" "") 
    "public sealed class $name$gen : ITuple$gen,IEquatable<$name$gen>, IComparable<$name$gen>,IComparable {" 
    (0..($count-1) | %{ Gen-Property $_ $mutable}) 
    Gen-Constructor $count $name 
    Gen-TupleAccess $count $mutable 
    Gen-Equals $count $name 
    Gen-GetHashCode $count 
    Gen-OpEquals $count $name 
    Gen-CompareTo $count $name 
    "}" 
    Gen-InferenceConstructor $count $name 
}

function Gen-TestTuple([int]$count, [string]$prefix) 
{ 
    $OFS = "," 
    $v = [string](0..($count-1) | %{ $valueList[$_]} ) 
    "[TestMethod]" 
    "public void {0}Access{1}() {{" -f $prefix,$count 
    "var t = $prefix.Create($v);" 
    for ( $i = 0; $i -lt $count; ++$i ) 
    { 
        "Assert.AreEqual({0},t.{1});" -f $valueList[$i],$upperList[$i]; 
    } 
    "}"

    "[TestMethod]" 
    "public void {0}GenericAccess{1}() {{" -f $prefix,$count 
    "var t = $prefix.Create($v);" 
    for ( $i = 0; $i -lt $count; ++$i ) 
    { 
        ("Assert.AreEqual({0},t[{1}]);" -f $valueList[$i],$i); 
    } 
    "Assert.AreEqual({0},t.Count);" -f $i 
    "}"

    "[TestMethod]" 
    "public void {0}Equals{1}() {{" -f $prefix,$count 
    "var t1 = $prefix.Create($v);" 
    "var t2 = $prefix.Create($v);" 
    "Assert.IsTrue(t1.Equals(t2));" 
    "}"

    "[TestMethod]" 
    "public void {0}NotEquals{1}() {{" -f $prefix,$count 
    for ( $i = 0; $i -lt $count; ++$i ) 
    { 
        $leftName = "t{0}_1" -f $i 
        $rightName = "t{0}_2" -f $i 
        $left = "var $leftName = $prefix.Create(" -f $i 
        $right = "var $rightName = $prefix.Create(" -f $i 
        for ( $v = 0; $v -lt $count; ++$v ) 
        { 
            $left += "$v" 
            if ( $v -eq $i ) 
            { 
                $right += "-1" 
            } 
            else 
            { 
                $right += "$v" 
            }

            if ( ($v + 1) -lt $count ) 
            { 
                $left += "," 
                $right += "," 
            } 
        } 
        "$left);" 
        "$right);" 
        "Assert.AreEqual($leftName.GetType(), $rightName.GetType());" 
        "Assert.IsFalse($leftName.Equals($rightName));" 
    } 
    "}"

    "[TestMethod]" 
    "public void {0}CompareTest() {{ " -f $prefix 
    "Assert.IsTrue($prefix.Create(1) < $prefix.Create(2));" 
    "Assert.IsTrue($prefix.Create(2) > $prefix.Create(1));" 
    "}" 
}

$output = 
@" 
using System; 
using System.Collections.Generic; 
using System.Diagnostics; 
using System.Diagnostics.CodeAnalysis;

namespace $namespace { 
public interface ITuple { 
    int Count { get; } 
    object this[int index] { get; } 
} 
"@ 
$OFS = [Environment]::NewLine 
$output += [string](0..($tupleCount-1) | %{ Gen-ITuple ($_+1) }) 
$output += [string](0..($tupleCount-1) | %{ Get-Tuple ($_+1) }) 
$output += [string](0..($tupleCount-1) | %{ Get-Tuple ($_+1) $true }) 
$output += "}"

$output > (join-path $scriptPath "Core\Tuple.cs")

$output = 
@" 
using System; 
using System.Collections.Generic; 
using Microsoft.VisualStudio.TestTools.UnitTesting; 
using $namespace;

namespace $($nameSpace)Test {

[TestClass] 
public class TupleTest{ 
"@ 
$output += Gen-TestTuple $tupleCount "Tuple" 
$output += Gen-TestTuple $tupleCount "MutableTuple" 
$output += "}}" 
$output > (join-path $scriptPath "TestCore\TupleTest.cs")
{% endraw %}
{% endhighlight %}

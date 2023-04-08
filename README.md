# Swift CLFormat

[![Platforms: macOS, iOS, Linux](https://img.shields.io/badge/Platforms-macOS,%20iOS,%20Linux-blue.svg?style=flat)](https://developer.apple.com/osx/) [![Language: Swift 5.7](https://img.shields.io/badge/Language-Swift%205.7-green.svg?style=flat)](https://developer.apple.com/swift/) [![IDE: Xcode 14](https://img.shields.io/badge/IDE-Xcode%2014-orange.svg?style=flat)](https://developer.apple.com/xcode/) [![Package managers: SwiftPM, Carthage](https://img.shields.io/badge/Package%20managers-SwiftPM,%20Carthage-8E64B0.svg?style=flat)](https://github.com/Carthage/Carthage) [![License: Apache](http://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat)](https://raw.githubusercontent.com/objecthub/swift-numberkit/master/LICENSE)

This framework implements
[Common Lisp's `format` procedure](https://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node200.html#SECTION002633000000000000000)
from scratch in Swift. `format` is a procedure that can produce formatted text using a
format string similar to the `printf` format string. The formatting formalism is
significantly more expressive compared to what `printf` has to offer. It allows users
to display numbers in various formats (e.g. hex, binary, octal, roman numerals, natural
language), apply conditional formatting, output text in a tabular format, iterate over
data structures, and even apply `format` recursively to handle data that includes their
own preferred formatting strings.

## API

### clformat and clprintf

The primary formatting procedure provided by framework _CLFormat_ is `clformat`. It has
the following signature:

```swift
func clformat(_ control: String,
              config: CLControlParserConfig? = CLControlParserConfig.default,
              locale: Locale? = nil,
              tabsize: Int = 4,
              linewidth: Int = 80,
              args: Any?...) throws -> String
```

`control` is the formatting string. It is using the formatting language described in the
next section to define how the output will be formatted. `config` refers to the control
parser configuration which determines how the control string gets parsed. This parameter
is omitted usually, unless a user wants to define its own control formatting
language. `locale` refers to a `Locale` object which is used for rendering 
locale-specific directives. `tabsize` defines the maximum number of space characters that
correspond to a single tab character. `linewidth` specifies the number of characters per
line (this is used by the justification directive only). Finally, `args` refers to the
sequence of arguments provided for inclusion in the formatting procedure. The control
string determines how these arguments will be injected into the final output that
function `clformat` returns.

There is also an overloaded variant of `clformat` which supports arguments provided as
an array. It is otherwise equivalent to the first variant.

```swift
func clformat(_ control: String,
              config: CLControlParserConfig? = CLControlParserConfig.default,
              locale: Locale? = nil,
              tabsize: Int = 4,
              linewidth: Int = 80,
              arguments: [Any?]) throws -> String
```

Finally, there are is an overloaded function `clprintf` which prints out the formatted
string directly to the standard output port. Via the `terminator` argument it is possible
to control whether a newline character is added automatically.

```swift
func clprintf(_ control: String,
              config: CLControlParserConfig? = CLControlParserConfig.default,
              locale: Locale? = nil,
              tabsize: Int = 4,
              linewidth: Int = 80,
              args: Any?...,
              terminator: String = "\n") throws
func clprintf(_ control: String,
              config: CLControlParserConfig? = CLControlParserConfig.default,
              locale: Locale? = nil,
              tabsize: Int = 4,
              linewidth: Int = 80,
              arguments: [Any?],
              terminator: String = "\n") throws
```

Note that, by default, both `clformat` and `clprintf` use the formatting directives as
specified by `CLControlParserConfig.default`. This is a mutable parser configuration that
can be used to influence all invocations of `clformat` and `clprintf` which don't provide
their own parser configuration.

### String extensions

Similar to how `printf` is integrated into Swift's `String` API, framework _CLFormat_
provides two new `String` initializers which make use of the _CLFormat_ formatting mechanism.
They can be used interchangably with `clformat` to allow for a more object-oriented style as
opposed to the procedural nature of `clformat`.

```swift
extension String {
  init(control: String,
       config: CLControlParserConfig? = nil,
       locale: Locale? = nil,
       tabsize: Int = 4,
       linewidth: Int = 80,
       args: Any?...) throws
  init(control: String,
       config: CLControlParserConfig? = nil,
       locale: Locale? = nil,
       tabsize: Int = 4,
       linewidth: Int = 80,
       arguments: [Any?]) throws
}
```

### Optimizing repeated formatting

Every single time `clformat` is being invoked, a control language parser is converting
the control string into an easier to process intermediate format. If a control string is
being used over and over again by a program, it makes sense to convert the control string
only once into its intermediate format and reuse it whenever a new list of arguments is
applied. The following code shows how to do that. Values of struct `CLControl` represent
the intermediate format of a given control string.

```swift
let control = try CLControl(string: "~A = ~,2F (time: ~4,1,,,'0Fms)")
let values: [[Any?]] = [["Stage 1", 317.452, 12.7],
                        ["Stage 2", 570.159, 41.2],
                        ["Stage 3", 123.745, 9.4]]
for args in values {
  print(try control.format(arguments: args))
}
```

This is the generated output:

```
Stage 1 = 317.45 (time: 12.7ms)
Stage 2 = 570.16 (time: 41.2ms)
Stage 3 = 123.74 (time: 09.4ms)
```

## Formatting language

The control string used by `clformat` and related functions and constructors consists of
characters that are copied verbatim into the output as well as _formatting directives_.
All formatting directives start with a tilde (`~`) and end with a single character
identifying the type of the directive. Directives may take prefix _parameters_ written
immediately after the tilde character, separated by comma. Both integers and characters
are allowed as parameters. They may be followed by formatting _modifiers_ `:`, `@`, and
`+`. This is the general format of a formatting directive:

```ebnf
~param1,param2,...mX

where m = (potentially empty) sequence of modifier characters ":", "@", and "+"
      X = character identifying the directive type
```

This grammar describes the syntax of directives formally:

```ebnf
<directive>  ::= "~" <modifiers> <char>
               | "~" <parameters> <modifiers> <char>
<modifiers>  ::= <empty>
               | ":" <modifiers>
               | "@" <modifiers>
               | "+" <modifiers>
<parameters> ::= <parameter>
               | <parameter> "," <parameters>
<parameter>  ::= <empty>
               | "#"
               | "v"
               | <number>
               | "-" <number>
               | <character>
<number>     ::= <digit>
               | <digit> <number>
<digit>      ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
<character>  ::= "'" <char>
```

The following sections introduce a few directives and explain how directives are
combined to build control strings that define expressive formatting instructions.

### Simple Directives

Here is a simple control string which injects a readable description of an argument via
the directive `~A`:

```
"I received ~A as a response"
```

Directive `~A` refers to a the _next argument_ provided to `clformat` when compiling the
formatted output:

```swift
clformat("I received ~A as a response", args: "nothing")
⇒ "I received nothing as a response"
clformat("I received ~A as a response", args: "a long email")
⇒ "I received a long email as a response"
```

Directive `~A` may be given parameters to influence the formatted output. The first
parameter of `~A`-directives defines the minimal length. If the length of the textual
representation of the next argument is smaller than the minimal length, padding characters
are inserted:

```swift
clformat("|Name: ~10A|Location: ~13A|", args: "Smith", "New York")
⇒ "|Name: Smith     |Location: New York     |"
clformat("|Name: ~10A|Location: ~13A|", args: "Williams", "San Francisco")
⇒ "|Name: Williams  |Location: San Francisco|"
clformat("|Name: ~10,,,'_@A|Location: ~13,,,'-A|", args: "Garcia", "Los Angeles")
⇒ "|Name: ____Garcia|Location: Los Angeles--|"
```

The third example above utilizes more than one parameter and, in one case, includes a
`@` modifier. The directive `~13,,,'-A` defines the first and the fourth parameter. The
second and third parameter are omitted and thus defaults are used. The fourth parameter
defines the padding character. If character literals are used in the parameter list,
they are prefixed with a quote `'`. The directive `~10,,,'_@A` includes an `@` modifier
which will result in padding of the output on the left.

It is possible to inject a parameter from the list of arguments. The following examples
show how parameter `v` is used to do this for formatting a floating-point number with
a configurable number of fractional digits.

```swift
clformat("length = ~,vF", args: 2, Double.pi)
⇒ "length = 3.14"
clformat("length = ~,vF", args: 4, Double.pi)
⇒ "length = 3.1416"
```

Here `v` is used as the second parameter of the fixed floating-point directive `~F`,
indicating the number of fractional digits. It refers to the next provided argument (which is
either 2 or 4 in the examples above).

### Composite Directives

The next example shows how one can refer to the total number of arguments that are not
yet consumed in the formatting process by using `#` as a parameter value.

```swift
clformat("~A left for formatting: ~#[none~;one~;two~:;many~].",
         args: "Arguments", "eins", 2)
⇒ "Arguments left for formatting: two."
clformat("~A left for formatting: ~#[none~;one~;two~:;many~].",
         args: "Arguments")
⇒ "Arguments left for formatting: none."
clformat("~A left for formatting: ~#[none~;one~;two~:;many~].",
         args: "Arguments", "eins", 2, "drei", "vier")
⇒ "Arguments left for formatting: many."
```

In these examples, the _conditional directive_ `~[` is used. It is followed by _clauses_
separared by directive `~;` until `~]` is reached. Thus, there are four clauses in the example
above: `none`, `one`, `two`, and `many`. The parameter in front of the `~[` directive
determines which of the clauses is being output. All other clauses will be discarded.
For instance, `~1[zero~;one~;two~:;many~]` will output `one` as clause 1 is chosen (which
is the second one, given that numbering starts with zero). The last clause is special because
it is prefixed with the `~;` directive using a `:` modifier: this is a _default clause_ which is
chosen when none of the others are applicable. Thus, `~8[zero~;one~;two~:;many~]` outputs
`many`. This also explains how the example above works: here `#` refers to the number of
arguments that are still available and this number drives what is being returned in this
directive: `~#[...~]`.

Another powerful composite directive is the _iteration directive_ `~{`. With this
directive it is possible to iterate over all elements of a sequence. The control string
between `~{` and `~}` gets repeated as long as there are still elements left in the
sequence which is provided as an argument. For instance, `Numbers:~{ ~A~}` applied to
argument `["one", "two", "three"]` results in the output `Numbers: one two three`.
The control string between `~{` and `~}` can also consume more than one element of the
sequence. Thus, `Numbers:~{ ~A=>~A~}` applied to argument `["one", 1, "two", 2]`
outputs `Numbers: one=>1 two=>2`.

Of course, it is also possible to nest arbitrary composite directives. Here is an example
for a control string that uses a combination of iteration and conditional directives to
output the elements of a sequence separated by a comma: `(~{~#[~;~A~:;~A, ~]~})`. When this
control string is used with the argument `["one", "two", "three"]`, the following formatted
output is generated: `(one, two, three)`.

## Formatting directive reference

The formatting directives supported by the _CLFormat_ framework are based on the directives
specified in [Common Lisp the Language, 2nd Edition](https://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node1.html)
by Guy L. Steele Jr. Some directives have been extended to meet today's formatting requirements
(e.g. to support localization) and to achieve a natural embedding in Swift. All extensions were
introduced in a way to not impact backward compatibility.

<table>
<thead>
  <tr><th>Directive</th><th>Explanation</th></tr>
</thead>
<tbody>
<tr valign="top">
  <td><b>~a</b><br/><b>~A</b></td>
  <td>
  <p><i>ASCII:</i>&nbsp;&nbsp;<b>~<i>mincol,colinc,minpad,padchar,maxcol,elchar</i>A</b></p>
  <p>The next argument <i>arg</i> is output without escape characters. In particular, if <i>arg</i>
     is a string, its characters will be output verbatim. If <i>arg</i> is nil, it will be output as
     <tt>nil</tt>. If <i>arg</i> is not nil, then the formatter will attempt to convert <i>arg</i>
     using one of the following properties (tried in the order as listed below) into a string that
     is output:</p>
  <ol>
     <li>If <i>arg</i> implements protocol <tt>CLFormatConvertible</tt> then property
        <tt>clformatDebugDescription</tt> will be output.</li>
     <li>If <i>arg</i> implements protocol <tt>CustomStringConvertible</tt> then property
         <tt>description</tt> will be output.</li>
     <li>String interpolation is used to turn <i>arg</i> into a string.
   </ol>
  <p><i>mincol</i> (default: 0) specifies the minimal "width" of the output of the directive
     in characters, <i>maxcol</i> (default: &infin;) specifies the maximum width. <i>padchar</i>
     (default: ' ') defines the character that is used to pad the output to make sure it is at
     least <i>mincol</i> characters long. By default, the output is padded on the right with
     at least <i>minpad</i> (default: 0) copies of <i>padchar</i>. Padding characters are then
     inserted <i>colinc</i> (default: 1) characters at a time until the total width is at
     least <i>mincol</i>. Padding is capped such that the output never exceeds <i>maxcol</i>
     characters. If, without padding, the output is already longer than <i>maxcol</i>, the
     output is truncated at width <i>maxcol - 1</i> and the ellipsis character <i>elchar</i>
     (default: '&hellip;') is inserted at the end.<p>
  <p>Modifier <tt>:</tt> enables debugging output, i.e. the following sequence of properties of
     <i>arg</i> are considered for generating the output:</p>
  <ol>
     <li>If <i>arg</i> implements protocol <tt>DebugCLFormatConvertible</tt> then property
         <tt>clformatDebugDescription</tt> will be output.</li>
     <li>If <i>arg</i> implements protocol <tt>CustomDebugStringConvertible</tt> then property
         <tt>debugDescription</tt> will be output.</li>
     <li>The properties as listed above are tried to generate the output.
  </ol>
  <p>Modifier <tt>@</tt> enables padding on the left to right-align the output.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~w</b><br/><b>~W</b></td>
  <td>
  <p><i>WRITE:</i>&nbsp;&nbsp;<b>~<i>mincol,colinc,minpad,padchar,maxcol,elchar</i>W</b></p>
  <p>The next argument <i>arg</i> is output without escape characters just as if it was
     printed via Swift's <tt>print</tt> function. If <i>arg</i> is nil, it will be output as
     <tt>nil</tt>. If <i>arg</i> is not nil, then the formatter will attempt to convert <i>arg</i>
     using one of the following properties (tried in the order as listed below) into a string that
     is output:</p>
  <ol>
     <li>If the <tt>:</tt> modifier was provided and <i>arg</i> implements protocol
         <tt>CustomDebugStringConvertible</tt> then property <tt>debugDescription</tt> will
         be output.</li>
     <li>If <i>arg</i> implements protocol <tt>CustomStringConvertible</tt> then property
         <tt>description</tt> will be output.</li>
     <li>String interpolation is used to turn <i>arg</i> into a string.
   </ol>
  <p>Parameters <i>mincol</i> (default: 0), <i>colinc</i> (default: 1), <i>minpad</i> (default: 0),
     <i>padchar</i> (default: ' '), <i>maxcol</i> (default: &infin;), and
     <i>elchar</i> (default: '&hellip;') are used just as described for the <i>ASCII directive</i>
     <tt>~A</tt>. Modifier <tt>:</tt> enables debugging output. Modifier <tt>@</tt> enables
     padding on the left to right-align the output.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~s</b><br/><b>~S</b></td>
  <td>
  <p><i>SOURCE:</i>&nbsp;&nbsp;<b>~<i>mincol,colinc,minpad,padchar,maxcol,elchar</i>S</b></p>
  <p>The next argument <i>arg</i> is output with escape characters. In particular, if <i>arg</i>
     is a string, double-quotes delimit the characters of the string. If <i>arg</i> is a character,
     single-quotes delimit the character. If <i>arg</i> is nil, it will be output as
     <tt>nil</tt>. For all other values, the formatter will attempt to convert <i>arg</i>
     using one of the following properties (tried in the order as listed below) into a string that
     is output:</p>
  <ol>
     <li>If the <tt>:</tt> modifier was provided and <i>arg</i> implements protocol
         <tt>DebugCLFormatConvertible</tt> then property <tt>clformatDebugDescription</tt> will
         be output.</li>
     <li>If the <tt>:</tt> modifier was provided and <i>arg</i> implements protocol
         <tt>CustomDebugStringConvertible</tt> then property <tt>debugDescription</tt> will
         be output.</li>
     <li>If <i>arg</i> implements protocol <tt>CLFormatConvertible</tt> then property
         <tt>clformatDescription</tt> will be output.</li>
     <li>If <i>arg</i> implements protocol <tt>CustomStringConvertible</tt> then property
         <tt>description</tt> will be output.</li>
     <li>String interpolation is used to turn <i>arg</i> into a string.
  </ol>
  <p>Parameters <i>mincol</i> (default: 0), <i>colinc</i> (default: 1), <i>minpad</i> (default: 0),
     <i>padchar</i> (default: ' '), <i>maxcol</i> (default: &infin;), and
     <i>elchar</i> (default: '&hellip;') are used just as described for the <i>ASCII directive</i>
     <tt>~A</tt>. Modifier <tt>:</tt> enables debugging output. Modifier <tt>@</tt> enables
     padding on the left to right-align the output.</p>
  </td>
</tr>
<tr valign="top">
  <td><b>~d</b><br/><b>~D</b></td>
  <td>
  <p><i>DECIMAL:</i>&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>D</b></p>
  <p>The next argument <i>arg</i> is output in decimal radix. <i>arg</i> should be an integer,
     in which case no decimal point is printed. For floating-point numbers which do not represent
     an integer, a decimal point and a fractional part are output.</p>
  <p><i>mincol</i> (default: 0) specifies the minimal "width" of the output of the directive
     in characters with <i>padchar</i> (default: ' ') defining the character that is used to
     pad the output on the left to make sure it is at least <i>mincol</i> characters long.</p>
  <p>&nbsp;&nbsp;<tt>clformat("Number: ~D", 8273)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;8273</tt><br />
     &nbsp;&nbsp;<tt>clformat("Number: ~6D", 8273)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;&nbsp;&nbsp;8273</tt><br />
     &nbsp;&nbsp;<tt>clformat("Number: ~6,'0D", 8273)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;008273</tt></p>
  <p>By default, the number is output without grouping separators. <i>groupchar</i> specifies
     which character should be used to separate sequences of <i>groupcol</i> digits in the
     output. Grouping of digits gets enabled with the <tt>:</tt> modifier.</p>
  <p>&nbsp;&nbsp;<tt>clformat("|~10:D|", 1734865)</tt> &DoubleLongRightArrow; <tt>|&nbsp;1,734,865|</tt><br />
     &nbsp;&nbsp;<tt>clformat("|~10,,'.:D|", 1734865)</tt> &DoubleLongRightArrow; <tt>|&nbsp;1.734.865|</tt></p>
  <p>A sign is output only if the number is negative. With the modifier <tt>@</tt> it is possible
     to force output also of positive signs. To facilitate the localization of output, function
     <tt>clformat</tt> supports a parameter <tt>locale:</tt>. Locale-specific
     output can be enabled by using the <tt>+</tt> modifier.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~+D", locale: Locale(identifier: "de_CH"), 14321)</tt> &DoubleLongRightArrow; <tt>14'321</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~b</b><br/><b>~B</b></td>
  <td>
  <p><i>BINARY:</i>&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>B</b></p>
  <p>Binary directive <tt>~B</tt> is just like decimal directive <tt>~D</tt> but it outputs
     the next argument in binary radix (radix 2) instead of decimal. It uses the space character
     as the default for <i>groupchar</i> and has a default grouping size of 4 as the default for
     <i>groupcol</i>.</p>
  <p>&nbsp;&nbsp;<tt>clformat("bin(~D) = ~B", 178, 178)</tt> &DoubleLongRightArrow; <tt>bin(178) = 10110010</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:B", 59701)</tt> &DoubleLongRightArrow; <tt>1110 1001 0011 0101</tt><br />
     &nbsp;&nbsp;<tt>clformat("~19,'0,'.:B", 31912)</tt> &DoubleLongRightArrow; <tt>0111.1100.1010.1000</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~o</b><br/><b>~O</b></td>
  <td>
  <p><i>OCTAL:</i>&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>O</b></p>
  <p>Octal directive <tt>~O</tt> is just like decimal directive <tt>~D</tt> but it outputs
     the next argument in octal radix (radix 8) instead of decimal. It uses the space character
     as the default for <i>groupchar</i> and has a default grouping size of 4 as the default for
     <i>groupcol</i>.</p>
  <p>&nbsp;&nbsp;<tt>clformat("bin(~D) = ~O", 178, 178)</tt> &DoubleLongRightArrow; <tt>bin(178) = 262</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:O", 59701)</tt> &DoubleLongRightArrow; <tt>16 4465</tt><br />
     &nbsp;&nbsp;<tt>clformat("~9,'0,',:O", 31912)</tt> &DoubleLongRightArrow; <tt>0007,6250</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~x</b><br/><b>~X</b></td>
  <td>
  <p><i>HEXADECIMAL:</i>&nbsp;&nbsp;<b>~<i>mincol,padchar,groupchar,groupcol</i>X</b></p>
  <p>Hexadecimal directive <tt>~X</tt> is just like decimal directive <tt>~D</tt> but it outputs
     the next argument in hexadecimal radix (radix 16) instead of decimal. It uses the colon character
     as the default for <i>groupchar</i> and has a default grouping size of 2 as the default for
     <i>groupcol</i>. With modifier <tt>+</tt>, upper case characters are used for representing
     hexadecimal digits.</p>
  <p>&nbsp;&nbsp;<tt>clformat("bin(~D) = ~X", 9968, 9968)</tt> &DoubleLongRightArrow; <tt>bin(9968) = 26f0</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:X", 999701)</tt> &DoubleLongRightArrow; <tt>f:41:15</tt><br />
     &nbsp;&nbsp;<tt>clformat("~+X", 999854)</tt> &DoubleLongRightArrow; <tt>F41AE</tt></p>
  </td>
</tr>
<tr valign="top">
  <td><b>~r</b><br/><b>~R</b></td>
  <td>
  <p><i>RADIX:</i>&nbsp;&nbsp;<b>~<i>radix,mincol,padchar,groupchar,groupcol</i>R</b></p>
  <p>The next argument <i>arg</i> is expected to be an integer. It will be output with radix
     <i>radix</i>. <i>mincol</i> (default: 0) specifies the minimal "width" of
     the output of the directive in characters with <i>padchar</i> (default: ' ') defining the
     character that is used to pad the output on the left to make it at least <i>mincol</i>
     characters long.</p>
  <p>&nbsp;&nbsp;<tt>clformat("Number: ~10R", 1272)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;1272</tt><br />
     &nbsp;&nbsp;<tt>clformat("Number: ~16,8,'0R", 7121972)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;006cac34</tt><br />
     &nbsp;&nbsp;<tt>clformat("Number: ~2R", 173)</tt> &DoubleLongRightArrow; <tt>Number:&nbsp;10101101</tt></p>
  <p>By default, the number is output without grouping separators. <i>groupchar</i> specifies
     which character should be used to separate sequences of <i>groupcol</i> digits in the
     output. Grouping of digits gets enabled with the <tt>:</tt> modifier.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~16,8,,':,2:R", 7121972)</tt> &DoubleLongRightArrow; <tt>6c:ac:34</tt><br />
     &nbsp;&nbsp;<tt>clformat("~2,14,'0,'.,4:R", 773)</tt> &DoubleLongRightArrow; <tt>0011.0000.0101</tt></p>
  <p>A sign is output only if the number is negative. With the modifier <tt>@</tt> it is possible
     to force output also of positive signs.</p>
  <p>If parameter <i>radix</i> is not specified at all, then an entirely different interpretation
     is given. <tt>~R</tt> outputs <i>arg</i> as a cardinal number in natural language. The form
     <tt>~:R</tt> outputs <i>arg</i> as an ordinal number in natural language. <tt>~@R</tt>
     outputs <i>arg</i> as a Roman numeral. By default, the language used is English. By specifying
     the <tt>+</tt> modifier, it is possible to switch the language to the language of the locale
     provided to function <tt>clformat</tt>.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~R", 572)</tt> <br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>five hundred seventy-two</tt><br />
     &nbsp;&nbsp;<tt>clformat("~:R", 3)</tt> <br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>3rd</tt><br />
     &nbsp;&nbsp;<tt>clformat("~@R", 1272)</tt> <br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>MCCLXXII</tt></p>
  <p>Modifier <tt>+</tt> plays two different roles: If the given radix is greater than 10, upper
     case characters are used for representing alphabetic digits. If the radix is omitted, 
     usage of modifier <tt>+</tt> enables locale-specific output defined by the <tt>locale:</tt>
     parameter of function <tt>clformat</tt>.</p>
  <p>&nbsp;&nbsp;<tt>clformat("~10+R", locale: Locale(identifier: "de_CH"), 14321)</tt> <br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>14'321</tt> <br />
     &nbsp;&nbsp;<tt>clformat("~+R", locale: Locale(identifier: "de_DE"), 572)</tt> <br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>fünf­hundert­zwei­und­siebzig</tt> <br />
     &nbsp;&nbsp;<tt>clformat("~16R vs ~16+R", 900939, 900939)</tt> <br />
     &nbsp;&nbsp;&nbsp;&nbsp;&DoubleLongRightArrow; <tt>dbf4b vs DBF4B</tt></p>
  </td>
</tr>
</tbody>
</table>

## Command-line tool

TODO

## Requirements

The following technologies are needed to build the _CLFormat_ framework. The library
and the command-line tool can both be built either using _Xcode_ or the _Swift Package Manager_.

- [Xcode 14](https://developer.apple.com/xcode/)
- [Swift 5.7](https://developer.apple.com/swift/)
- [Swift Package Manager](https://swift.org/package-manager/)

## Copyright

Author: Matthias Zenger (<matthias@objecthub.com>)  
Copyright © 2023 Matthias Zenger. All rights reserved.

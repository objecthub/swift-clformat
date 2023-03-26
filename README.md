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

## Formatting language

The control string used by `clformat` and related functions and constructors consists of
characters that are copied verbatim into the output as well as _formatting directives_.
All formatting directives start with a tilde (`~`) and end with a single character
identifying the directive type. Directives may take prefix _parameters_ written immediately
after the tilde character, separated by comma. Both integers and characters are allowed
as parameters. They may be followed by formatting _modifiers_ `:`, `@`, and `+`. This is
the general format of a formatting directive:

```
~param1,param2,...mX

where m is a (potentially empty) sequence of modifier characters :, @, and +
      X is a character identifying the directive type
```

Here is a simple control string which injects a readable description of an argument via
the directive `~A`:

```
"I received ~A as a response"
```

Directive `~A` refers to a the next argument provided to `clformat` when compiling the
formatted output:

```swift
clformat("I received ~A as a response", args: "nothing")
⇒ "I received nothing as a response"
clformat("I received ~A as a response", args: "a long email")
⇒ "I received a long email as a response"
```

Directive `~A` may be provided parameters to influence the formatted output. The first
parameter defines a minimal length. If the length of the textual representation of the
next argument is smaller than the minimal lenght, padding characters are inserted:

```
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
which will result in the output to be padded on the left.

## Supported formatting directives

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

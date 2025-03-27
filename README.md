# Swift CLFormat

[![Platforms: macOS, iOS, Linux](https://img.shields.io/badge/Platforms-macOS,%20iOS,%20Linux-blue.svg?style=flat)](https://developer.apple.com/osx/) [![Language: Swift 6](https://img.shields.io/badge/Language-Swift%206-green.svg?style=flat)](https://developer.apple.com/swift/) [![IDE: Xcode 16](https://img.shields.io/badge/IDE-Xcode%2014-orange.svg?style=flat)](https://developer.apple.com/xcode/) [![Package managers: SwiftPM, Carthage](https://img.shields.io/badge/Package%20managers-SwiftPM,%20Carthage-8E64B0.svg?style=flat)](https://github.com/Carthage/Carthage) [![License: Apache](http://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat)](https://raw.githubusercontent.com/objecthub/swift-numberkit/master/LICENSE)

This framework implements
[Common Lisp's `format` procedure](https://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node200.html#SECTION002633000000000000000)
from scratch in Swift. `format` is a procedure that produces formatted text using a
format string similar to `printf`. The formatting formalism is significantly more expressive
compared to `printf`. It allows users to display numbers in various formats (e.g. hex, binary,
octal, roman numerals, natural language), apply conditional formatting, output text in a
tabular format, iterate over data structures, and even apply `format` recursively to handle
data that includes their own preferred formatting strings.

The documentation of this framework includes:

  - The [<tt>clformat</tt> API](#API),
  - A description of the [formatting language](#formatting-language),
  - A comprehensive list of the [supported formatting directives](DIRECTIVES.md),
  - A short introduction of the [command-line tool](#command-line-tool), and
  - [Technical requirements](#requirements) for using this framework.

Here are a few examples to get a quick impression of the usage of <tt>clformat</tt>:

```swift
clformat("~D message~:P received. Average latency: ~,2Fms.", args: 17, 4.2567)
⇒ "17 messages received. Average latency: 4.26ms."
clformat("~D file~:P ~A. Average latency: ~,2Fms.", args: 1, "stored", 68.1)
⇒ "1 file stored. Average latency: 68.10ms."
```

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
next section to define how the output will be formatted. `config` refers to the
[format configuration](https://github.com/objecthub/swift-clformat/blob/main/Sources/CLFormat/CLFormatConfig.swift)
which determines how the control string and the arguments get parsed and interpreted. This
parameter gets usually omitted, unless a user wants to define their own control formatting
language. `locale` refers to a `Locale` object which is used for executing
locale-specific directives. `tabsize` defines the maximum number of space characters that
correspond to a single tab character. `linewidth` specifies the number of characters per
line (this is used by the justification directive only). Finally, `args` refers to the
sequence of arguments provided for inclusion in the formatting procedure. The control
string determines how these arguments will be injected into the final output that
function `clformat` returns. Here is an example:

```swift
try clformat("~A is ~D year~:P old.", args: "John", 32)
⇒ "John is 32 years old."
try clformat("~A is ~D year~:P old.", args: "Vicky", 1)
⇒ "Vicky is 1 year old."
```

There is also an [overloaded variant](https://github.com/objecthub/swift-clformat/blob/7b1b0ab894180449101330c867e740463e5e38d5/Sources/CLFormat/CLFormat.swift#L131)
of `clformat` which supports arguments provided as
an array. It is otherwise equivalent to the first variant.

```swift
func clformat(_ control: String,
              config: CLControlParserConfig? = CLControlParserConfig.default,
              locale: Locale? = nil,
              tabsize: Int = 4,
              linewidth: Int = 80,
              arguments: [Any?]) throws -> String
```

Finally, there are is an [overloaded function](https://github.com/objecthub/swift-clformat/blob/7b1b0ab894180449101330c867e740463e5e38d5/Sources/CLFormat/CLFormat.swift#L157)
`clprintf` which prints out the formatted
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
specified by [`CLControlParserConfig.default`](https://github.com/objecthub/swift-clformat/blob/7b1b0ab894180449101330c867e740463e5e38d5/Sources/CLFormat/CLControlParserConfig.swift#L239).
This is a mutable parser configuration that
can be used to influence all invocations of `clformat` and `clprintf` which don't provide
their own parser configuration.

### String extensions

Similar to how `printf` is integrated into Swift's `String` API, framework _CLFormat_
provides two new [`String` initializers](https://github.com/objecthub/swift-clformat/blob/7b1b0ab894180449101330c867e740463e5e38d5/Sources/CLFormat/CLFormat.swift#L87)
which make use of the _CLFormat_ formatting mechanism.
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
characters that are copied verbatim into the output as well as
[_formatting directives_](DIRECTIVES.md). All formatting directives start with a
tilde (`~`) and end with a single character identifying the type of the directive.
Directives may take prefix _parameters_ written immediately after the tilde
character, separated by comma. Both integers and characters are allowed as parameters.
They may be followed by formatting _modifiers_ `:`, `@`, and `+`. This is the general
format of a formatting directive:

```ebnf
~param1,param2,...mX

where m = (potentially empty) sequence of modifier characters ":", "@", and "+"
      X = character identifying the directive type
```

This grammar describes the syntax of directives formally in BNF:

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

The [formatting directives supported by the _CLFormat_ framework](DIRECTIVES.md)
are based on the directives specified in
[Common Lisp the Language, 2nd Edition](https://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node1.html)
by Guy L. Steele Jr. Some directives have been extended to meet today's formatting requirements
(e.g. to support localization) and to achieve a natural embedding in Swift. All extensions were
introduced in a way to not impact backward compatibility. 

## Command-line tool

The <tt>swift-clformat</tt> framework also includes a command-line tool for experimenting
with <tt>clformat</tt> control strings. It prompts users to first enter a control string
followed by a list of arguments. The syntax of control strings is described above. The
argument list is entered in a syntax that is close to the syntax literals have in Swift.
Here is an example for an interaction with the command-line tool:

```swift
═════════╪═══════════════════════════
  CONTROL│ Done.~^ ~D warning~:P.~^ ~D error~:P.
ARGUMENTS│ 1, 5
─────────┤
   RESULT│ Done. 1 warning. 5 errors.
═════════╪═══════════════════════════
  CONTROL│ ~%;; ~{~<~%;; ~1,30:; ~S~>~^,~}.~%
ARGUMENTS│ ["first line", "second", "a long third line", "fourth"]
─────────┤
   RESULT│ 
         │ ;;  "first line", "second",
         │ ;;  "a long third line",
         │ ;;  "fourth".
         │ 
═════════╪═══════════════════════════
  CONTROL│ ~:{/~S~^ ...~}
ARGUMENTS│ [["hot", "dog"], ["hamburger"], ["ice", "cream"]]
─────────┤
   RESULT│ /"hot" .../"hamburger"/"ice" ...
═════════╪═══════════════════════════
```

## Requirements

The following technologies are needed to build the _CLFormat_ framework. The library
and the command-line tool can both be built either using _Xcode_ or the _Swift Package Manager_.

- [Xcode 16](https://developer.apple.com/xcode/)
- [Swift 6](https://developer.apple.com/swift/)
- [Swift Package Manager](https://swift.org/package-manager/)
- [MarkdownKit](http://github.com/objecthub/swift-markdownkit)

## Copyright

Author: Matthias Zenger (<matthias@objecthub.com>)  
Copyright © 2023-2025 Matthias Zenger. All rights reserved.

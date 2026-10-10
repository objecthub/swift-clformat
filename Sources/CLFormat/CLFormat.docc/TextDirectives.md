# Text and character directives

Output arguments as text, characters, or plurals.

## ASCII (\~A)

**Syntax:** **\~**_mincol,colinc,minpad,padchar,maxcol,elchar_**A**

The next argument *arg* is output without escape characters. In particular, if *arg* is a string, its characters will be output verbatim. If *arg* is nil, it will be output as `nil`. If *arg* is not nil, then the formatter will attempt to convert *arg* using one of the following properties (tried in the order as listed below) into a string that is output:

1. If *arg* implements protocol `CLFormatConvertible` then property `clformatDescription` will be output.
2. If *arg* implements protocol `CustomStringConvertible` then property `description` will be output.
3. String interpolation is used to turn *arg* into a string.

*mincol* (default: 0) specifies the minimal "width" of the output of the directive in characters, *maxcol* (default: ∞) specifies the maximum width. *padchar* (default: ' ') defines the character that is used to pad the output to make sure it is at least *mincol* characters long. By default, the output is padded on the right with at least *minpad* (default: 0) copies of *padchar*. Padding characters are then inserted *colinc* (default: 1) characters at a time until the total width is at least *mincol*. Padding is capped such that the output never exceeds *maxcol* characters. If, without padding, the output is already longer than *maxcol*, the output is truncated at width *maxcol - 1* and the ellipsis character *elchar* (default: '…') is inserted at the end.

Modifier `:` enables debugging output, i.e. the following sequence of properties of *arg* are considered for generating the output:

1. If *arg* implements protocol `DebugCLFormatConvertible` then property `clformatDebugDescription` will be output.
2. If *arg* implements protocol `CustomDebugStringConvertible` then property `debugDescription` will be output.
3. The properties as listed above are tried to generate the output.

Modifier `@` enables padding on the left to right-align the output.

## Write (\~W)

**Syntax:** **\~**_mincol,colinc,minpad,padchar,maxcol,elchar_**W**

The next argument *arg* is output without escape characters just as if it was printed via Swift's `print` function. If *arg* is nil, it will be output as `nil`. If *arg* is not nil, then the formatter will attempt to convert *arg* using one of the following properties (tried in the order as listed below) into a string that is output:

1. If the `:` modifier was provided and *arg* implements protocol `CustomDebugStringConvertible` then property `debugDescription` will be output.
2. If *arg* implements protocol `CustomStringConvertible` then property `description` will be output.
3. String interpolation is used to turn *arg* into a string.

Parameters *mincol* (default: 0), *colinc* (default: 1), *minpad* (default: 0), *padchar* (default: ' '), *maxcol* (default: ∞), and *elchar* (default: '…') are used just as described for the *ASCII directive* `~A`. Modifier `:` enables debugging output. Modifier `@` enables padding on the left to right-align the output.

## Source (\~S)

**Syntax:** **\~**_mincol,colinc,minpad,padchar,maxcol,elchar_**S**

The next argument *arg* is output with escape characters. In particular, if *arg* is a string, double-quotes delimit the characters of the string. If *arg* is a character, single-quotes delimit the character. If *arg* is nil, it will be output as `nil`. For all other values, the formatter will attempt to convert *arg* using one of the following properties (tried in the order as listed below) into a string that is output:

1. If the `:` modifier was provided and *arg* implements protocol `DebugCLFormatConvertible` then property `clformatDebugDescription` will be output.
2. If the `:` modifier was provided and *arg* implements protocol `CustomDebugStringConvertible` then property `debugDescription` will be output.
3. If *arg* implements protocol `CLFormatConvertible` then property `clformatDescription` will be output.
4. If *arg* implements protocol `CustomStringConvertible` then property `description` will be output.
5. String interpolation is used to turn *arg* into a string.

Parameters *mincol* (default: 0), *colinc* (default: 1), *minpad* (default: 0), *padchar* (default: ' '), *maxcol* (default: ∞), and *elchar* (default: '…') are used just as described for the *ASCII directive* `~A`. Modifier `:` enables debugging output. Modifier `@` enables padding on the left to right-align the output.

## Character (\~C)

**Syntax:** **\~C**

The next argument *arg* should be a character. Directive `~C` outputs *arg* in a form dependent on the modifiers used. Without any modifiers, *arg* is output as if the character was used in a string.

If the `@` modifier is provided, a representation based on *Unicode scalars* is chosen. Without further modifiers, *arg* is output using Swift's Unicode scalar escape syntax `\u{...}` so that the result can be used within a Swift string literal. By adding the `+` modifier, the result is automatically surrounded by double-quotes. The modifier combination `@:` will lead to *arg* being output as Unicode code points. The combination `@:+` will output *arg* as a sequence of Unicode scalar property names, separated by comma.

If the `:` modifier is used (without `@`), a representation of *arg* for the usage in XML documents is chosen. By default, a Unicode-based XML character encoding is used, unless `:` is combined with `+`, in which case the character is represented as a XML named character entity when possible, otherwise, the character is output in raw form.

```swift
try clformat("~C", args: "A")
⇒ A
try clformat("~@C", args: "A")
⇒ \u{41}
try clformat("~@+C", args: "A")
⇒ "\u{41}"
try clformat("~@:C", args: "©")
⇒ U+00A9
try clformat("~@:+C", args: "©")
⇒ COPYRIGHT SIGN
try clformat("~:C", args: "©")
⇒ &#xA9;
try clformat("~:+C", args: "©")
⇒ &copy;
```

## Plural (\~P)

**Syntax:** **\~P**

Depending on the next argument *arg*, which is expected to be an integer value, a different string is output. If *arg* is not equal to 1, a lowercase `s` is output. If *arg* is equal to 1, nothing is output.

If the `:` modifier is provided, the last argument is used instead for *arg*. This is useful after outputting a number using `~D`. With the `@` modifier, `y` is output if *arg* is 1, or `ies` if it is not.

```swift
try clformat("~D tr~:@P/~D win~:P", args: 7, 1)
⇒ 7 tries/1 win
try clformat("~D tr~:@P/~D win~:P", args: 1, 0)
⇒ 1 try/0 wins
```

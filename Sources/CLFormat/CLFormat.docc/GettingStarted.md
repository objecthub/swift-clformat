# Getting started with CLFormat

Format values with `clformat`, reuse control strings, and adapt the output to locales.

## Overview

The primary function is ``clformat(_:config:locale:tabsize:linewidth:displayWidth:args:)``.
It takes a control string followed by the arguments to format and returns the formatted string:

```swift
try clformat("~A is ~D year~:P old.", args: "John", 32)
// "John is 32 years old."
try clformat("~A is ~D year~:P old.", args: "Vicky", 1)
// "Vicky is 1 year old."
```

Directives start with a tilde (`~`), optionally followed by comma-separated _parameters_ and
the modifiers `:`, `@`, and `+`, and end with a character that identifies the directive. For
example, `~,2F` prints a floating-point number with two fractional digits, and `~:D` groups
the digits of an integer.

```swift
try clformat("~,2F", args: 3.14159)                 // "3.14"
try clformat("~:D", args: 1234567)                  // "1,234,567"
try clformat("~@R", args: 1994)                     // "MCMXCIV"
try clformat("~R", args: 21)                        // "twenty-one"
try clformat("~{~A~^, ~}", args: ["a", "b", "c"])   // "a, b, c"
```

Parameters can also be taken from the arguments by using `v`, or be set to the number of
remaining arguments with `#`:

```swift
try clformat("|~vA|", args: 6, "text")              // "|text  |"
```

### Strings and printing

There are equivalent ways to format values. The `String` initializers integrate with Swift's
`String` API, and ``clprintf(_:config:locale:tabsize:linewidth:displayWidth:args:terminator:)``
prints the result to the standard output:

```swift
let message = try String(control: "~D item~:P", args: 3)
try clprintf("Total: ~D item~:P", args: 3)
```

### Reusing control strings

Every call of ``clformat(_:config:locale:tabsize:linewidth:displayWidth:args:)`` parses the
control string. If a control string is used repeatedly, parse it once with ``CLControl`` and
format it as often as needed. A ``CLControl`` value is immutable and can be used from several
threads at the same time:

```swift
let control = try CLControl(string: "~A = ~,2F")
for (name, value) in [("pi", 3.14159), ("e", 2.71828)] {
  print(try control.format(args: name, value))
}
```

### Locales and display width

Locale-specific output is enabled with the `+` modifier together with the `locale` parameter:

```swift
let german = Locale(identifier: "de_DE")
try clformat("~,2:+F", locale: german, args: 1234.5)    // "1.234,50"
```

By default, padding and justification count characters. Setting `displayWidth` to `true` uses
the width a string occupies in a terminal instead, which aligns text containing emoji:

```swift
try clformat("|~4A|", displayWidth: true, args: "✅")   // "|✅  |"
```

### Handling errors

Control strings are validated while they are parsed, and arguments are checked while they are
formatted. Both report problems by throwing errors instead of crashing:

```swift
do {
  _ = try clformat("~D", args: "text")
} catch let error as CLFormatError {
  print(error)   // expected argument 0 to be a number; instead it is text
} catch let error as CLControlError {
  print(error)   // e.g. unknown directive ~Q
}
```

Numeric parameters are limited to the range from `-Parameters.maxNumber` to
`Parameters.maxNumber`.

### Formatting custom types

Types can control how they appear in the output of the `~A` and `~S` directives by conforming
to ``CLFormatConvertible``. Conforming to ``DebugCLFormatConvertible`` provides the
representation used by the `:` modifier (`~:A`).

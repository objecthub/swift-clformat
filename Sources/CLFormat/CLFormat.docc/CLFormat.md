# ``CLFormat``

Format text with the expressive control strings of Common Lisp's `format`.

## Overview

_CLFormat_ implements Common Lisp's `format` procedure in Swift. A _control string_ combines
literal text with _directives_ that format their arguments. Directives can display numbers in
many representations (decimal, binary, hexadecimal, roman numerals, natural language, currency
amounts), select between alternatives, iterate over sequences, justify and align text, and
change the case of the output.

```swift
try clformat("~D message~:P received. Average latency: ~,2Fms.", args: 17, 4.2567)
// "17 messages received. Average latency: 4.26ms."
try clformat("~D file~:P ~A. Average latency: ~,2Fms.", args: 1, "stored", 68.1)
// "1 file stored. Average latency: 68.10ms."
```

The framework is thread-safe: parsed controls (``CLControl``), format configurations
(``CLFormatConfig``), and all value types are `Sendable`. Formatting never traps on malformed
control strings or unusual arguments; it throws a ``CLControlError`` or a ``CLFormatError``
instead.

The complete list of supported directives is documented in the <doc:Directives>.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Directives>
- ``clformat(_:config:locale:tabsize:linewidth:displayWidth:args:)``
- ``clformat(_:config:locale:tabsize:linewidth:displayWidth:arguments:)``
- ``clprintf(_:config:locale:tabsize:linewidth:displayWidth:args:terminator:)``
- ``clprintf(_:config:locale:tabsize:linewidth:displayWidth:arguments:terminator:)``
- ``Swift/String/init(control:config:locale:tabsize:linewidth:displayWidth:args:)``
- ``Swift/String/init(control:config:locale:tabsize:linewidth:displayWidth:arguments:)``

### Formatting a control string repeatedly

- ``CLControl``
- ``Context``
- ``Instruction``

### Customizing the formatting language

- <doc:CustomDirectives>
- ``CLFormatConfig``
- ``CLControlParser``
- ``DirectiveParser``
- ``ParseResult``
- ``DirectiveSpecifier``
- ``StandardDirectiveSpecifier``
- ``Directive``
- ``Parameter``
- ``Parameters``
- ``Modifiers``

### Arguments

- ``Arguments``
- ``CLFormatConvertible``
- ``DebugCLFormatConvertible``
- ``unwrapAny(_:)``

### Numbers and currencies

- ``Number``
- ``NumberFormat``
- ``Currency``

### Errors

- ``CLControlError``
- ``CLFormatError``

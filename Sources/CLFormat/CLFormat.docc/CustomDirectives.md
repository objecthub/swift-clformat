# Adding custom directives

Extend the formatting language with your own directives, or remove standard ones.

## Overview

The directives that are available for a control string are defined by a ``CLFormatConfig``. The
configuration maps directive characters to parsers. ``CLFormatConfig/standard`` implements all
standard directives. Copy it and modify the copy to define your own formatting language:

```swift
var config = CLFormatConfig.standard
config.remove("W", "w")                       // remove directive ~W
config.parse("Z", appending: ReverseSpecifier())

try clformat("~Z", config: config, args: "abc")    // "cba"
```

### Implementing a directive

A directive is implemented by a type conforming to ``DirectiveSpecifier``. It identifies the
directive character and interprets the parameters, modifiers, and arguments of a directive when
it is applied. Directive specifiers must be `Sendable` since parsed controls can be shared
between threads.

```swift
struct ReverseSpecifier: DirectiveSpecifier {
  var identifier: Character { return "Z" }
  var description: String { return "Z" }
  func apply(context: Context,
             parameters: Parameters,
             modifiers: Modifiers,
             arguments: Arguments) throws -> Instruction {
    return .append(String(try arguments.nextAsString().reversed()))
  }
}
```

Specifiers return an ``Instruction``: `append` adds text to the output, `continue` ends the
current iteration, and `break` leaves the enclosing iteration.

### Custom directive parsers

Most directives do not need special parsing because the control string parser handles
parameters and modifiers generically. Composite directives, such as iterations, parse the part
of the control string they enclose. For these, register a ``DirectiveParser`` which receives the
``CLControlParser`` and returns a ``ParseResult``:

```swift
config.parse("y", "Y") { parser, parameters, modifiers in
  return .append(parameters, modifiers, StandardDirectiveSpecifier.decimal)
}
```

### Custom arguments and global defaults

``CLFormatConfig/setArgumentFactory(makeArguments:)`` replaces the factory for the
``Arguments`` objects that provide the arguments to directives. A subclass of ``Arguments``
can, for instance, change which values count as `nil` or as boolean values.
The ``CLFormatConfig/environment`` stores additional values for custom directives, and
``CLFormatConfig/nilRepresentation`` determines how `nil` is printed.

``CLFormatConfig/default`` is used by ``clformat(_:config:locale:tabsize:linewidth:displayWidth:args:)``
and ``clprintf(_:config:locale:tabsize:linewidth:displayWidth:args:terminator:)`` if no
configuration is passed explicitly. Reading and writing it is thread-safe, but modifying single
properties is not atomic, so configure it once at startup.

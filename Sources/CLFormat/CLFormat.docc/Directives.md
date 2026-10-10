# Directive reference

All directives supported by the formatting language, with parameters, modifiers, and examples.

## Overview

The formatting directives supported by the _CLFormat_ framework are based on the directives specified in [Common Lisp the Language, 2nd Edition](https://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node1.html) by Guy L. Steele Jr. Some directives have been extended to meet today's formatting requirements (e.g. to support localization) and to achieve a natural embedding in Swift. All extensions were introduced in a way to not impact backward compatibility.

### Syntax of directives

Every directive starts with a tilde (`~`), is followed by optional comma-separated _parameters_ and optional _modifiers_, and ends with a character that identifies the directive:

```
~param1,param2,...mX

where m = (potentially empty) sequence of modifier characters ":", "@", and "+"
      X = character identifying the directive type
```

Directive characters that are letters can be written in lower or upper case: `~a` and `~A` are the same directive. A parameter is one of the following:

- An integer, such as `~10D` or `~,2,-2F`. Integer parameters must be in the range from -1,000,000 to 1,000,000 (see ``Parameters/maxNumber``).
- A character, written with a leading quote, such as `~10,'0D`.
- The letter `v`, which takes the value of the parameter from the next argument, such as `~vD`.
- The character `#`, which stands for the number of arguments that are left, such as `~#D`.
- Nothing: omitted parameters have default values, such as in `~,2F`. Trailing parameters can be left out entirely.

The modifiers `:`, `@`, and `+` change the behavior of a directive in ways that are described with each directive. They can be combined, in any order. Locale-specific output is typically requested with the `+` modifier, in combination with the `locale:` parameter of ``clformat(_:config:locale:tabsize:linewidth:displayWidth:args:)``.

### Overview of directives

| Directive | Name | Purpose |
|---|---|---|
| `~A` | [ASCII](doc:TextDirectives) | Outputs an argument as text, without escape characters. |
| `~W` | [Write](doc:TextDirectives) | Outputs an argument like Swift's `print` function. |
| `~S` | [Source](doc:TextDirectives) | Outputs an argument with escape characters, delimiting strings and characters. |
| `~C` | [Character](doc:TextDirectives) | Outputs a character as text, as Unicode scalars, or as XML. |
| `~P` | [Plural](doc:TextDirectives) | Outputs a plural suffix depending on a number. |
| `~D` | [Decimal](doc:IntegerDirectives) | Outputs an integer in decimal notation, with optional grouping. |
| `~B` | [Binary](doc:IntegerDirectives) | Outputs an integer in binary notation. |
| `~O` | [Octal](doc:IntegerDirectives) | Outputs an integer in octal notation. |
| `~X` | [Hexadecimal](doc:IntegerDirectives) | Outputs an integer in hexadecimal notation. |
| `~R` | [Radix](doc:IntegerDirectives) | Outputs an integer in any radix, in natural language, or as an ordinal or roman numeral. |
| `~F` | [Fixed float](doc:FloatDirectives) | Outputs a floating-point number in fixed-point notation. |
| `~E` | [Exponential float](doc:FloatDirectives) | Outputs a floating-point number in exponential notation. |
| `~G` | [General float](doc:FloatDirectives) | Outputs a floating-point number in fixed-point or exponential notation. |
| `~$` | [Dollars float](doc:FloatDirectives) | Outputs a monetary amount, optionally with a currency symbol. |
| `~%` | [Newline](doc:LayoutDirectives) | Outputs newlines. |
| `~&` | [Freshline](doc:LayoutDirectives) | Outputs a newline unless the output is at the beginning of a line. |
| `~\|` | [Page separator](doc:LayoutDirectives) | Outputs page separator characters. |
| `~~` | [Tilde](doc:LayoutDirectives) | Outputs tilde characters. |
| `~T` | [Tabulate](doc:LayoutDirectives) | Moves to a column by outputting spaces. |
| `~`*newline* | [Line continuation](doc:LayoutDirectives) | Ignores a newline in the control string. |
| `~<…~>` | [Justification](doc:LayoutDirectives) | Justifies text within a field of a given width. |
| `~*` | [Ignore argument](doc:ControlDirectives) | Skips arguments or jumps to another argument. |
| `~?` | [Indirection](doc:ControlDirectives) | Processes an argument as a control string. |
| `~(…~)` | [Conversion](doc:ControlDirectives) | Converts case, or escapes the enclosed output. |
| `~[…~]` | [Conditional](doc:ControlDirectives) | Selects one of several control strings. |
| `~{…~}` | [Iteration](doc:ControlDirectives) | Repeats a control string for the elements of a sequence. |
| `~^` | [Up and out](doc:ControlDirectives) | Terminates an iteration or justification early. |

## Topics

### Directives by category

- <doc:TextDirectives>
- <doc:IntegerDirectives>
- <doc:FloatDirectives>
- <doc:LayoutDirectives>
- <doc:ControlDirectives>

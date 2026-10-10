# Changelog

## 1.4 (2026-10-11)
- Adopt the Swift 6 language mode. All public value types are now `Sendable` (`CLControl`, `Directive`, `Parameters`, `Number`, `Currency`, `Context`, ...), as are the error types and `CLFormatConfig`. A parsed `CLControl` can be formatted concurrently from several threads.
- `DirectiveSpecifier` now refines `Sendable`. Custom directive specifiers have to be `Sendable`, i.e. they must not have mutable state.
- Make `CLFormatConfig.default` thread-safe. Changing it while formatting on other threads used to be a data race.
- Fix `displayWidth` being ignored inside iterations (`~{`, `~:{`, `~@{`) and indirections (`~?`)
- Fix `NSDecimalNumber` arguments being converted to `Double`, which lost precision
- Report the parameters of malformed closing directives (e.g. `~1)`) in the error message
- Add DocC documentation, including a complete reference of all directives and articles on getting started and on adding custom directives, and installation instructions to the README
- Document directive `~` followed by a newline (line continuation) in the directive reference, and correct a few errors in it (the results of the `Pairs` examples of `~{`, and the conversion method listed for `CLFormatConvertible` in `~A`)
- Extend the test suite considerably, in particular for errors, currencies, and less common directives

## 1.3 (2026-10-10)
- Fix crashes and hangs caused by edge-case control strings and arguments:
  - `~wF` (width, no fraction digits) crashed for every negative number
  - `~E`, `~G`, and `~wF` crashed for infinity and NaN; they are now rendered as `+∞`, `-∞`, and `NaN`, padded to the requested width
  - `~w,d,eE` crashed if the exponent has more digits than requested via `e`
  - `~E` and `~G` crashed for zero fraction digits combined with a scale factor `k <= 0`
  - A column increment of 0 (e.g. `~5,0A` and `~5,0<...~>`) caused a division by zero; it is now treated like 1
  - A maximum column of 0 crashed `~A`, `~S`, and `~W` for one-character strings
  - `~nR` crashed for radix `n` outside of 2...36; it now throws `CLFormatError.cannotRepresentNumber`
  - A group size of 0 (e.g. `~,,' ,0:X`) caused an infinite loop; grouping is now skipped
  - `Currency(numericCode:)` and `~$` crashed for numeric codes outside of the `UInt16` range; they now return `nil` and omit the currency symbol, respectively
  - A tab size of 0 or less crashed `~T`; tabs now count as a single column
- Fix `~E` and `~G` for scale factors `k <= 0`: large integers printed the digits of `Int.max` and large shifts printed `∞`
- Limit numeric directive parameters to the range -1,000,000...1,000,000 (see `Parameters.maxNumber`). Larger values used to overflow or exhaust memory. They are now rejected with `CLControlError.malformedNumericParameter` (control string) or `CLFormatError.cannotUseArgumentAsParameter` (parameter `v`).
- Raise the minimum platform versions to macOS 12 (was 11) and watchOS 9 (was 8), as required by the Xcode 27 SDKs; iOS 15 and tvOS 15 are unchanged. visionOS 1 is now supported.
- Require MarkdownKit 2.0 and CommandLineKit 1.1.2; the package now uses `swift-tools-version` 6.0
- Fix the deprecation warning for `Locale.currencyCode`
- Make the Xcode project consistent with `Package.swift` (deployment targets); the `CLFormat` scheme now builds for iOS, tvOS, watchOS, and visionOS
- Migrate to Xcode 27
- Add regression tests for all fixed crashes and hangs

## 1.2.1 (2026-06-12)
- Fix the `CommandLineKit` product dependency in `Package.swift`

## 1.2 (2026-06-12)
- Support a new boolean `displayWidth` parameter (for all `clformat`-related functions) which uses the terminal width of characters to implement justification and padding-related directives (vs. the number of characters). This makes it possible to align output containing emojies.
- Migrate to Xcode 26
- Now dependent also on `swift-commandlinekit` 

## 1.1.1 (2025-03-28)
- Migrate to Xcode 16
- Require latest version of MarkdownKit

## 1.1 (2024-05-12)
- Force grouping if locale is supposed to be used for decimal directive
- Use the locale only if the `+` modifier is provided for directive `~$`
- Ignore Package.resolved

## 1.0.10 (2023-05-30)
- Simplify management of directive application contexts
- Optimize access to format configurations
- Fix platform constraints in Package.swift

## 1.0.5 (2023-05-21)
- Fix argument propagation to support all attribute metadata
- Support generic metadata at config-level (via an environment)

## 1.0.3 (2023-05-14)
- Improve returned error messages.
- Make more of the API public to allow for reuse in extensions.
- Fix localized number representations.

## 1.0.2 (2023-05-13)
- Externalize all critical protocols
- Refactor all error data types
- Provide better error reporting

## 1.0 (2023-05-07)
- Initial release
- Support for all directives supported by Common Lisp's `format` (where this makes sense)
- Regression test suite
- Comprehensive documentation

## 0.1 (2023-03-15)
- Initial, incomplete code
- Work in progress

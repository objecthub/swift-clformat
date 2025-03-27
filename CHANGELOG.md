# Changelog

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

# Swift CLFormat

[![Platforms: macOS, iOS, Linux](https://img.shields.io/badge/Platforms-macOS,%20iOS,%20Linux-blue.svg?style=flat)](https://developer.apple.com/osx/) [![Language: Swift 5.7](https://img.shields.io/badge/Language-Swift%205.7-green.svg?style=flat)](https://developer.apple.com/swift/) [![IDE: Xcode 14](https://img.shields.io/badge/IDE-Xcode%2014-orange.svg?style=flat)](https://developer.apple.com/xcode/) [![Package managers: SwiftPM, Carthage](https://img.shields.io/badge/Package%20managers-SwiftPM,%20Carthage-8E64B0.svg?style=flat)](https://github.com/Carthage/Carthage) [![License: Apache](http://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat)](https://raw.githubusercontent.com/objecthub/swift-numberkit/master/LICENSE)

This framework implements Common Lisp's `format` procedure from scratch in Swift.
`format` is a procedure that can produce formatted text using a format string
similar to the `printf` format string. The formatting formalism is significantly
more expressive compared to what `printf` has to offer. It allows users to display
numbers in various formats (e.g. hex, binary, octal, roman numerals, and even in a
natural language), apply conditional formatting, output text in a tabular format,
iterate over data structures, and even apply `format` recursively to
handle data that includes their own preferred formatting strings.

## API

TODO

## Formatting language

TODO

## Supported formatting directives

TODO

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

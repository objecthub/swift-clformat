//
//  ControlParser.swift
//  CommonLispFormat
//
//  Created by Matthias Zenger on 05/03/2023.
//  Copyright © 2023 Matthias Zenger. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
//  implied. See the License for the specific language governing
//  permissions and limitations under the License.
//

import Foundation


class ControlParser {
  let config: ControlParserConfig
  let control: String
  var i: String.Index
  
  init(control: String, config: ControlParserConfig) {
    self.config = config
    self.control = control
    self.i = control.startIndex
  }
  
  func nextChar() throws -> Character {
    self.i = self.control.index(after: i)
    if self.i < self.control.endIndex {
      return self.control[i]
    } else {
      throw ControlParsingError.prematureEndOfControl
    }
  }
  
  func parse() throws -> (Control, Directive?) {
    var components = [Control.Component]()
    var start = self.i
    while i < control.endIndex {
      var ch = self.control[self.i]
      if ch == "~" {
        if start < i {
          components.append(.text(self.control[start..<self.i]))
        }
        var params = [Parameter]()
        var modifiers = Modifiers()
        parseparams: repeat {
          ch = try self.nextChar()
          switch ch {
            case "#":
              params.append(.remainingArguments)
              ch = try self.nextChar()
            case "v", "V":
              params.append(.nextArgument)
              ch = try self.nextChar()
            case "'":
              params.append(.character(try self.nextChar()))
              ch = try self.nextChar()
            case "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
              var numstr = String(ch)
              if ch == "-" {
                ch = try self.nextChar()
                switch ch {
                  case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                    numstr.append(ch)
                  default:
                    throw ControlParsingError.malformedNumericParameter("\(numstr)\(ch)")
                }
              }
              ch = try self.nextChar()
              while ch == "0" || ch == "1" || ch == "2" || ch == "3" ||
                    ch == "4" || ch == "5" || ch == "6" || ch == "7" ||
                    ch == "8" || ch == "9" {
                numstr.append(ch)
                ch = try self.nextChar()
              }
              if let num = Int(numstr, radix: 10) {
                params.append(.number(num))
              } else {
                throw ControlParsingError.malformedNumericParameter(numstr)
              }
            case ",":
              params.append(.none)
            default:
              break parseparams
          }
        } while ch == ","
        parsemods: while true {
          switch ch {
            case ":":
              if modifiers.contains(.colon) {
                throw ControlParsingError.duplicateModifier(":")
              }
              modifiers.insert(.colon)
              ch = try self.nextChar()
            case "@":
              if modifiers.contains(.at) {
                throw ControlParsingError.duplicateModifier("@")
              }
              modifiers.insert(.at)
              ch = try self.nextChar()
            case "+":
              if modifiers.contains(.plus) {
                throw ControlParsingError.duplicateModifier("+")
              }
              modifiers.insert(.plus)
              ch = try self.nextChar()
            default:
              break parsemods
          }
        }
        if let parser = self.config.directiveParsers[ch] {
          switch try parser(self, Parameters(params), modifiers) {
            case .append(let directive):
              components.append(.directive(directive))
            case .exit(let directive):
              return (Control(components: components, config: self.config), directive)
          }
        } else {
          throw ControlParsingError.unknownDirective("~" + String(ch))
        }
        self.i = control.index(after: self.i)
        start = i
      } else {
        self.i = control.index(after: self.i)
      }
    }
    if start < self.control.endIndex {
      components.append(.text(self.control[start..<self.control.endIndex]))
    }
    return (Control(components: components, config: self.config), nil)
  }
  
  func parse() throws -> Control {
    let (control, directive) = try self.parse()
    if let directive = directive {
      switch directive.specifier.identifier {
        case StandardDirectiveSpecifier.separator.identifier,
             StandardDirectiveSpecifier.conversionEnd.identifier,
             StandardDirectiveSpecifier.conditionalEnd.identifier,
             StandardDirectiveSpecifier.iterationEnd.identifier:
          throw ControlParsingError.misplacedDirective(directive.description)
        default:
          throw ControlParsingError.prematureEndOfControl
      }
    }
    return control
  }
}

struct ControlParserConfig {
  var directiveParsers: [Character : DirectiveParser] = [:]
  
  mutating func parse(_ chars: [Character], with parser: @escaping DirectiveParser) {
    for char in chars {
      self.directiveParsers[char] = parser
    }
  }
  
  mutating func parse(_ chars: Character..., with parser: @escaping DirectiveParser) {
    for char in chars {
      self.directiveParsers[char] = parser
    }
  }
  
  mutating func parse(_ chars: Character..., appending specifier: DirectiveSpecifier) {
    self.parse(chars) { parser, parameters, modifiers in
      return .append(Directive(parameters: parameters,
                               modifiers: modifiers,
                               specifier: specifier))
    }
  }
  
  static let standard: ControlParserConfig = {
    var config = ControlParserConfig()
    config.parse("a", "A", appending: StandardDirectiveSpecifier.ascii)
    config.parse("s", "S", appending: StandardDirectiveSpecifier.sexpr)
    config.parse("d", "D", appending: StandardDirectiveSpecifier.decimal)
    config.parse("r", "R", appending: StandardDirectiveSpecifier.radix)
    config.parse("b", "B", appending: StandardDirectiveSpecifier.binary)
    config.parse("o", "O", appending: StandardDirectiveSpecifier.octal)
    config.parse("x", "X", appending: StandardDirectiveSpecifier.hexadecimal)
    config.parse("c", "C", appending: StandardDirectiveSpecifier.character)
    config.parse("f", "F", appending: StandardDirectiveSpecifier.fixedFloat)
    config.parse("e", "E", appending: StandardDirectiveSpecifier.exponentFloat)
    config.parse("g", "G", appending: StandardDirectiveSpecifier.generalFloat)
    config.parse("g", "$", appending: StandardDirectiveSpecifier.moneyAmount)
    config.parse("p", "P", appending: StandardDirectiveSpecifier.plural)
    config.parse("t", "T", appending: StandardDirectiveSpecifier.tabular)
    config.parse("~",      appending: StandardDirectiveSpecifier.tilde)
    config.parse("%",      appending: StandardDirectiveSpecifier.percent)
    config.parse("&",      appending: StandardDirectiveSpecifier.ampersand)
    config.parse("|",      appending: StandardDirectiveSpecifier.bar)
    config.parse("~",      appending: StandardDirectiveSpecifier.tilde)
    config.parse("*",      appending: StandardDirectiveSpecifier.ignoreArgs)
    config.parse("^",      appending: StandardDirectiveSpecifier.upAndOut)
    config.parse("?",      appending: StandardDirectiveSpecifier.indirection)
    config.parse("(") { parser, parameters, modifiers in
      _ = try parser.nextChar()
      let (control, directive) = try parser.parse()
      guard let directive = directive,
            directive.specifier.identifier == StandardDirectiveSpecifier.conversionEnd.identifier else {
        throw ControlParsingError.malformedDirectiveSyntax("conversion", "~(...~)")
      }
      return .append(parameters, modifiers, StandardDirectiveSpecifier.conversion(control))
    }
    config.parse(")") { parser, parameters, modifiers in
      guard parameters.parameterCount == 0,
            !modifiers.contains(.at), !modifiers.contains(.colon) else {
        throw ControlParsingError.malformedDirective("~\(modifiers))")
      }
      return .exit(parameters, modifiers, StandardDirectiveSpecifier.conversionEnd)
    }
    config.parse("[") { parser, parameters, modifiers in
      var alternatives = [Control]()
      var def = false
      _ = try parser.nextChar()
      while true {
        let (control, directive) = try parser.parse()
        alternatives.append(control)
        if let dir = directive {
          if dir.specifier.identifier == StandardDirectiveSpecifier.separator.identifier {
            guard !def else {
              throw ControlParsingError.malformedDirectiveSyntax("conditional", "~[...~:;...~]")
            }
            if dir.modifiers.contains(.colon) {
              def = true
            }
            continue
          } else if dir.specifier.identifier == StandardDirectiveSpecifier.conditionalEnd.identifier {
            break
          }
        }
        throw ControlParsingError.malformedDirectiveSyntax("conditional", "~[...~]")
      }
      return .append(parameters, modifiers, StandardDirectiveSpecifier.conditional(alternatives, def))
    }
    config.parse("]") { parser, parameters, modifiers in
      guard parameters.parameterCount == 0,
            !modifiers.contains(.at), !modifiers.contains(.colon) else {
        throw ControlParsingError.malformedDirective("~\(modifiers)]")
      }
      return .exit(parameters, modifiers, StandardDirectiveSpecifier.conditionalEnd)
    }
    config.parse(";") { parser, parameters, modifiers in
      guard parameters.parameterCount == 0, !modifiers.contains(.at) else {
        throw ControlParsingError.malformedDirective("~:;")
      }
      parser.i = parser.control.index(after: parser.i)
      return .exit(parameters,modifiers, StandardDirectiveSpecifier.separator)
    }
    config.parse("{") { parser, parameters, modifiers in
      _ = try parser.nextChar()
      let (control, directive) = try parser.parse()
      guard let directive = directive,
            directive.specifier.identifier == StandardDirectiveSpecifier.iterationEnd.identifier else {
        throw ControlParsingError.malformedDirectiveSyntax("iteration", "~{...~}")
      }
      return .append(parameters, modifiers, StandardDirectiveSpecifier.iteration(control))
    }
    config.parse("}") { parser, parameters, modifiers in
      guard parameters.parameterCount == 0,
            !modifiers.contains(.at), !modifiers.contains(.colon) else {
        throw ControlParsingError.malformedDirective("~\(modifiers)}")
      }
      return .exit(parameters, modifiers, StandardDirectiveSpecifier.iterationEnd)
    }
    return config
  }()
}

/// A directive parser is a function that takes a control parser, parameters, and
/// modifiers generating a parse result message. Most directive parsers don't really
/// parse anything (parsing of parameters and modifiers is done generically already
/// by the control parser), they simply package up parameters and modifiers in a new
/// directive.
typealias DirectiveParser = (ControlParser, Parameters, Modifiers) throws -> ParseResult

/// Directive parsers generate `ParseResult` values as their result
enum ParseResult {
  case append(Directive)
  case exit(Directive)
  
  /// Convenience method for generating an append result with a new directive
  static func append(_ parameters: Parameters,
                     _ modifiers: Modifiers,
                     _ spec: DirectiveSpecifier) -> ParseResult {
    return .append(Directive(parameters: parameters, modifiers: modifiers, specifier: spec))
  }
  
  /// Convenience method for generating an exit result with a new directive
  static func exit(_ parameters: Parameters,
                   _ modifiers: Modifiers,
                   _ spec: DirectiveSpecifier) -> ParseResult {
    return .exit(Directive(parameters: parameters, modifiers: modifiers, specifier: spec))
  }
}

enum ControlParsingError: Error, CustomStringConvertible {
  case prematureEndOfControl
  case duplicateModifier(String)
  case malformedParameter
  case malformedNumericParameter(String)
  case malformedDirectiveSyntax(String, String)
  case malformedDirective(String)
  case misplacedDirective(String)
  case unsupportedDirective(String)
  case unknownDirective(String)
  
  var description: String {
    switch self {
      case .prematureEndOfControl:
        return "premature end of control"
      case .duplicateModifier(let mod):
        return "duplicate modifier \(mod)"
      case .malformedParameter:
        return "malformed parameter"
      case .malformedNumericParameter(let param):
        return "malformed numeric parameter: \(param)"
      case .malformedDirectiveSyntax(let name, let dirs):
        return "malformed \(name) syntax \(dirs)"
      case .malformedDirective(let dir):
        return "malformed directive \(dir)"
      case .misplacedDirective(let dir):
        return "directive \(dir) in unsupported place"
      case .unsupportedDirective(let dir):
        return "unsupported directive \(dir)"
      case .unknownDirective(let dir):
        return "unknown directive \(dir)"
    }
  }
}

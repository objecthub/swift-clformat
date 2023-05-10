//
//  ControlParser.swift
//  CLFormat
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

///
/// Implementation of a control string parser. The parser implements a generic
/// directive parser which then triggers directive-specific parsers that handle
/// composite directives (such as conversion, iteration, justification, and
/// conditional directives).
/// 
public class CLControlParser {
  internal let config: CLFormatConfig
  internal let control: String
  internal var i: String.Index
  
  public init(control: String, config: CLFormatConfig) {
    self.config = config
    self.control = control
    self.i = control.startIndex
  }
  
  public func lookaheadChar() -> Character? {
    let i = self.control.index(after: i)
    return i < self.control.endIndex ? self.control[i] : nil
  }
  
  public func nextChar() throws -> Character {
    self.i = self.control.index(after: i)
    if self.i < self.control.endIndex {
      return self.control[i]
    } else {
      throw CLControlError.prematureEndOfControl
    }
  }
  
  public func parse() throws -> (CLControl, Directive?) {
    var components = [CLControl.Component]()
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
                    throw CLControlError.malformedNumericParameter("\(numstr)\(ch)")
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
                throw CLControlError.malformedNumericParameter(numstr)
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
                throw CLControlError.duplicateModifier(":")
              }
              modifiers.insert(.colon)
              ch = try self.nextChar()
            case "@":
              if modifiers.contains(.at) {
                throw CLControlError.duplicateModifier("@")
              }
              modifiers.insert(.at)
              ch = try self.nextChar()
            case "+":
              if modifiers.contains(.plus) {
                throw CLControlError.duplicateModifier("+")
              }
              modifiers.insert(.plus)
              ch = try self.nextChar()
            default:
              break parsemods
          }
        }
        if let parser = self.config.parser(for: ch) {
          switch try parser(self, Parameters(params), modifiers) {
            case .ignore:
              break
            case .append(let directive):
              components.append(.directive(directive))
            case .exit(let directive):
              return (CLControl(components: components, config: self.config), directive)
          }
        } else {
          throw CLControlError.unknownDirective("~" + String(ch))
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
    return (CLControl(components: components, config: self.config), nil)
  }
  
  public func parse() throws -> CLControl {
    let (control, directive) = try self.parse()
    if let directive = directive {
      switch directive.specifier.identifier {
        case StandardDirectiveSpecifier.separator.identifier,
             StandardDirectiveSpecifier.conversionEnd.identifier,
             StandardDirectiveSpecifier.conditionalEnd.identifier,
             StandardDirectiveSpecifier.iterationEnd.identifier:
          throw CLControlError.misplacedDirective(directive.description)
        default:
          throw CLControlError.prematureEndOfControl
      }
    }
    return control
  }
}

/// A directive parser is a function that takes a control parser, parameters, and
/// modifiers generating a parse result message. Most directive parsers don't really
/// parse anything (parsing of parameters and modifiers is done generically already
/// by the control parser), they simply package up parameters and modifiers in a new
/// directive.
public typealias DirectiveParser = (CLControlParser, Parameters, Modifiers) throws -> ParseResult

/// Directive parsers generate `ParseResult` values as their result
public enum ParseResult {
  case ignore
  case append(Directive)
  case exit(Directive)
  
  /// Convenience method for generating an append result with a new directive
  public static func append(_ parameters: Parameters,
                            _ modifiers: Modifiers,
                            _ spec: DirectiveSpecifier) -> ParseResult {
    return .append(Directive(parameters: parameters, modifiers: modifiers, specifier: spec))
  }
  
  /// Convenience method for generating an exit result with a new directive
  public static func exit(_ parameters: Parameters,
                          _ modifiers: Modifiers,
                          _ spec: DirectiveSpecifier) -> ParseResult {
    return .exit(Directive(parameters: parameters, modifiers: modifiers, specifier: spec))
  }
}

///
/// Enumeration encapsulating all parsing errors for the built-in directive
/// parsers.
/// 
public enum CLControlError: Error, CustomStringConvertible {
  case prematureEndOfControl
  case duplicateModifier(String)
  case malformedParameter
  case malformedNumericParameter(String)
  case malformedDirectiveSyntax(String, String)
  case malformedDirective(String)
  case misplacedDirective(String)
  case unsupportedDirective(String)
  case unknownDirective(String)
  
  public var description: String {
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

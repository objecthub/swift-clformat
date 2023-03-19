//
//  ControlParserConfig.swift
//  CLFormat
//
//  Created by Matthias Zenger on 19/03/2023.
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
/// A control parser config value contains a mapping from directive identifiers
/// (characters) to directive parsers which parse the directive. Most directive
/// are atomic (i.e. they are not composite) and parsing for those is trivial:
/// they just package up the generically parsed parameters and modifiers in a
/// new directive specifier value. Composite directives have more complex parsing
/// logic.
/// 
public struct ControlParserConfig {
  public private(set) var directiveParsers: [Character : DirectiveParser] = [:]
  
  public mutating func parse(_ chars: [Character], with parser: @escaping DirectiveParser) {
    for char in chars {
      self.directiveParsers[char] = parser
    }
  }
  
  public mutating func parse(_ chars: Character..., with parser: @escaping DirectiveParser) {
    for char in chars {
      self.directiveParsers[char] = parser
    }
  }
  
  public mutating func parse(_ chars: Character..., appending specifier: DirectiveSpecifier) {
    self.parse(chars) { parser, parameters, modifiers in
      return .append(Directive(parameters: parameters,
                               modifiers: modifiers,
                               specifier: specifier))
    }
  }
  
  public static let standard: ControlParserConfig = {
    var config = ControlParserConfig()
    config.parse("a", "A", appending: StandardDirectiveSpecifier.ascii)
    config.parse("w", "W", appending: StandardDirectiveSpecifier.write)
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
    config.parse("$",      appending: StandardDirectiveSpecifier.moneyAmount)
    config.parse("p", "P", appending: StandardDirectiveSpecifier.plural)
    config.parse("t", "T", appending: StandardDirectiveSpecifier.tabular)
    config.parse("%",      appending: StandardDirectiveSpecifier.percent)
    config.parse("&",      appending: StandardDirectiveSpecifier.ampersand)
    config.parse("|",      appending: StandardDirectiveSpecifier.bar)
    config.parse("~",      appending: StandardDirectiveSpecifier.tilde)
    config.parse("*",      appending: StandardDirectiveSpecifier.ignoreArgs)
    config.parse("^",      appending: StandardDirectiveSpecifier.upAndOut)
    config.parse("?",      appending: StandardDirectiveSpecifier.indirection)
    config.parse("\n") { parser, parameters, modifiers in
      if modifiers.contains(.colon) && modifiers.contains(.at) {
        throw ControlParsingError.malformedDirective("~:@\\n")
      } else if modifiers.contains(.colon) {
        return .ignore
      }
      while let next = parser.lookaheadChar(), next == " " {
        _ = try parser.nextChar()
      }
      if modifiers.contains(.at) {
        return .append(Parameters(), Modifiers(), StandardDirectiveSpecifier.percent)
      } else {
        return .ignore
      }
    }
    config.parse("(") { parser, parameters, modifiers in
      _ = try parser.nextChar()
      let (control, directive) = try parser.parse()
      guard let directive = directive,
            directive.specifier.identifier ==
              StandardDirectiveSpecifier.conversionEnd.identifier else {
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
          } else if dir.specifier.identifier ==
                      StandardDirectiveSpecifier.conditionalEnd.identifier {
            break
          }
        }
        throw ControlParsingError.malformedDirectiveSyntax("conditional", "~[...~]")
      }
      return .append(parameters,
                     modifiers,
                     StandardDirectiveSpecifier.conditional(alternatives, def))
    }
    config.parse("]") { parser, parameters, modifiers in
      guard parameters.parameterCount == 0,
            !modifiers.contains(.at), !modifiers.contains(.colon) else {
        throw ControlParsingError.malformedDirective("~\(modifiers)]")
      }
      return .exit(parameters, modifiers, StandardDirectiveSpecifier.conditionalEnd)
    }
    config.parse(";") { parser, parameters, modifiers in
      guard parameters.parameterCount == 0 ||
              (parameters.parameterCount <= 2 && modifiers.contains(.colon)),
            !modifiers.contains(.at) else {
        throw ControlParsingError.malformedDirective("~:;")
      }
      parser.i = parser.control.index(after: parser.i)
      return .exit(parameters, modifiers, StandardDirectiveSpecifier.separator)
    }
    config.parse("{") { parser, parameters, modifiers in
      _ = try parser.nextChar()
      let (control, directive) = try parser.parse()
      guard let directive = directive,
            directive.specifier.identifier ==
              StandardDirectiveSpecifier.iterationEnd.identifier else {
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
    config.parse("<") { parser, parameters, modifiers in
      var sections = [Control]()
      var spare: Int? = nil
      var width: Int? = nil
      _ = try parser.nextChar()
      while true {
        let (control, directive) = try parser.parse()
        sections.append(control)
        if let dir = directive {
          if dir.specifier.identifier == StandardDirectiveSpecifier.separator.identifier {
            if dir.modifiers.contains(.colon) {
              guard sections.count == 1 else {
                throw ControlParsingError.malformedDirectiveSyntax("justification", "~<...~:;...~>")
              }
              spare = try dir.parameters.number(0) ?? 0
              width = try dir.parameters.number(1)
            }
            continue
          } else if dir.specifier.identifier ==
                      StandardDirectiveSpecifier.justificationEnd.identifier {
            break
          }
        }
        throw ControlParsingError.malformedDirectiveSyntax("justification", "~<...~>")
      }
      guard !parameters.parameterProvided(4) || sections.count == 1 else {
        throw ControlParsingError.malformedDirectiveSyntax("justification", "~,,,,X<...~>")
      }
      return .append(parameters,
                     modifiers,
                     StandardDirectiveSpecifier.justification(sections, spare, width))
    }
    config.parse(">") { parser, parameters, modifiers in
      guard parameters.parameterCount == 0,
            !modifiers.contains(.at), !modifiers.contains(.colon) else {
        throw ControlParsingError.malformedDirective("~\(modifiers)>")
      }
      return .exit(parameters, modifiers, StandardDirectiveSpecifier.justificationEnd)
    }
    return config
  }()
}

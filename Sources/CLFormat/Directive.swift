//
//  Directive.swift
//  CLFormat
//
//  Created by Matthias Zenger on 07/03/2023.
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
/// Struct `Directive` represents a formatting directive consisting of parameters,
/// modifiers, and a directive specifier. The directive specifier is used to
/// identify what type of directive this is. It also contains any directive-specific
/// data (e.g. for the composite directives, such as iteration, conditional,
/// conversation, and justification).
/// 
public struct Directive: CustomStringConvertible {
  
  /// The parameters of this directive.
  public let parameters: Parameters
  
  /// The modifiers of this directive.
  public let modifiers: Modifiers
  
  /// The specifier of this directive.
  public let specifier: DirectiveSpecifier
  
  /// Directive constructor.
  public init(parameters: Parameters, modifiers: Modifiers, specifier: DirectiveSpecifier) {
    self.parameters = parameters
    self.modifiers = modifiers
    self.specifier = specifier
  }
  
  /// Returns a description of the directive in a synax similar to the one used by
  /// the control language.
  public var description: String {
    return "~\(self.parameters)\(self.modifiers)\(self.specifier)"
  }
}

/// Protocol defining directive specifiers.
public protocol DirectiveSpecifier: CustomStringConvertible {
  
  /// The character identifying a directive type.
  var identifier: Character { get }
  
  /// A function that applies a directive in a formatting context, by interpreting
  /// the given parameters, modifiers, and arguments. Such `apply` functions return
  /// a formatting instruction which gets executed by the generic format function.
  func apply(context: Context,
             parameters: Parameters,
             modifiers: Modifiers,
             arguments: Arguments) throws -> Instruction
}

/// Supported formatting instructions, declared as an enumeration.
/// 
///   - `append(str)` instructs the formatter to append `str` to the formatted output
///   - `continue(str)` instructs the formatter to append `str` to the formatted
///     output and to proceed processing the next section/iteration (depending on
///     context)
///   - `break(str)` instructs the formatter to append `str` to the formatted output
///     and to skip all remaining iterations (can only be used in the body of an
///     iteration directive)
public enum Instruction: Equatable {
  case `append`(String)       // Append the string to the output
  case `continue`(String)     // Stop the current iteration and continue with next
  case `break`(String)        // Exit the iteration
  
  public var string: String {
    switch self {
      case .append(let str):
        return str
      case .continue(let str):
        return str
      case .break(let str):
        return str
    }
  }
}

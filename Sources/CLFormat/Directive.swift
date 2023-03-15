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

public struct Directive: CustomStringConvertible {
  public let parameters: Parameters
  public let modifiers: Modifiers
  public let specifier: DirectiveSpecifier
  
  public init(parameters: Parameters, modifiers: Modifiers, specifier: DirectiveSpecifier) {
    self.parameters = parameters
    self.modifiers = modifiers
    self.specifier = specifier
  }
  
  public var description: String {
    return "~\(self.parameters)\(self.modifiers)\(self.specifier)"
  }
}

public protocol DirectiveSpecifier: CustomStringConvertible {
  var identifier: Character { get }
  func apply(context: Context,
             parameters: Parameters,
             modifiers: Modifiers,
             arguments: Arguments) throws -> Instruction
}

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

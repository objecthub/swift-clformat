//
//  CLControlError.swift
//  CLFormat
//
//  Created by Matthias Zenger on 12/05/2023.
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
/// Enumeration encapsulating all parsing errors for the built-in directive parsers.
///
public enum CLControlError: LocalizedError, CustomStringConvertible {
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
  
  public var errorDescription: String? {
    return self.description
  }
  
  public var failureReason: String? {
    return "syntax error in control string"
  }
}

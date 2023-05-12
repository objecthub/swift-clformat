//
//  CLFormatError.swift
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
/// Enumeration encapsulating all formatting errors for the built-in directives.
///
public enum CLFormatError: LocalizedError, CustomStringConvertible {
  case malformedDirective(String)
  case unsupportedDirective(String)
  case argumentOutOfRange(Int, Int)
  case missingArgument
  case expectedNumberArgument(Int, Any)
  case expectedSequenceArgument(Int, Any)
  case cannotUseArgumentAsParameter(Int, Any)
  case missingNumberParameter(Int)
  case expectedNumberParameter(Int, Any?)
  case expectedPositiveNumberParameter(Int, Any?)
  case missingCharacterParameter(Int)
  case expectedCharacterParameter(Int, Any?)
  case missingSequenceParameter(Int)
  case expectedSequenceParameter(Int, Any?)
  case cannotRepresentNumber(Number, Int)
  
  public var description: String {
    switch self {
      case .malformedDirective(let dir):
        return "malformed directive \(dir) in control string"
      case .unsupportedDirective(let dir):
        return "unsupported directive \(dir) in control string"
      case .argumentOutOfRange(let i, let n):
        return "cannot access argument \(i); only \(n) arguments in total"
      case .missingArgument:
        return "missing argument"
      case .expectedNumberArgument(let n, let arg):
        return "expected argument \(n) to be a number; instead it is \(arg)"
      case .expectedSequenceArgument(let n, let arg):
        return "expected argument \(n) to be a sequence; instead it is \(arg)"
      case .cannotUseArgumentAsParameter(let n, let arg):
        return "cannot use argument \(n) as parameter: \(arg)"
      case .missingNumberParameter(let n):
        return "missing number parameter \(n)"
      case .expectedNumberParameter(let n, let param):
        if let param = param {
          return "expected parameter \(n) to be a number, instead it is \(param)"
        } else {
          return "expected parameter \(n) to be a number, instead it is nil"
        }
      case .expectedPositiveNumberParameter(let n, let param):
        if let param = param {
          return "expected parameter \(n) to be a non-negative number, instead it is \(param)"
        } else {
          return "expected parameter \(n) to be a non-negative number, instead it is nil"
        }
      case .missingCharacterParameter(let n):
        return "missing character parameter \(n)"
      case .expectedCharacterParameter(let n, let param):
        if let param = param {
          return "expected parameter \(n) to be a character, instead it is \(param)"
        } else {
          return "expected parameter \(n) to be a character, instead it is nil"
        }
      case .missingSequenceParameter(let n):
        return "missing sequence parameter \(n)"
      case .expectedSequenceParameter(let n, let param):
        if let param = param {
          return "expected parameter \(n) to be a sequence, instead it is \(param)"
        } else {
          return "expected parameter \(n) to be a sequence, instead it is nil"
        }
      case .cannotRepresentNumber(let num, let radix):
        return "cannot represent \(num) with radix \(radix)"
    }
  }
  
  public var errorDescription: String? {
    return self.description
  }
  
  public var failureReason: String? {
    switch self {
      case .malformedDirective(_):
        return "illegal combination of directive parameters"
      case .unsupportedDirective(_):
        return "implementation limitation"
      case .argumentOutOfRange(_, _):
        return "illegal argument"
      case .missingArgument:
        return "too few arguments"
      case .expectedNumberArgument(_, _):
        return "argument is expected to be a number"
      case .expectedSequenceArgument(_, _):
        return "argument is expected to be a sequence"
      case .cannotUseArgumentAsParameter(_, _):
        return "illegal argument"
      case .missingNumberParameter(_),
           .missingCharacterParameter(_),
           .missingSequenceParameter(_):
        return "missing parameter"
      case .expectedNumberParameter(_, _),
           .expectedPositiveNumberParameter(_, _),
           .expectedCharacterParameter(_, _),
           .expectedSequenceParameter(_, _):
        return "wrong parameter type"
      case .cannotRepresentNumber(_, _):
        return "illegal radix"
    }
  }
}

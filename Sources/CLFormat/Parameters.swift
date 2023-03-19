//
//  Parameters.swift
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
/// Enumeration `Parameter` lists all possible types of directive parameters.
/// Supported are:
/// 
///   - `none`: No parameter is specified.
///   - `nextArgument`: The parameter is specified by the next argument.
///   - `remainingArguments`: The parameter is a number corresponding to the remaining
///     number of unprocessed arguments.
///   - `number(N)`: Represents the integer `N`.
///   - `character(C)`: Represents the character `C`.
/// 
public enum Parameter: Equatable, CustomStringConvertible {
  case none
  case nextArgument
  case remainingArguments
  case number(Int)
  case character(Character)
  
  /// Returns a description of the parameter that can also be read by the format
  /// parser.
  public var description: String {
    switch self {
      case .none:
        return ""
      case .nextArgument:
        return "v"
      case .remainingArguments:
        return "#"
      case .number(let n):
        return String(n)
      case .character(let ch):
        return "'\(ch)"
    }
  }
}

///
/// Struct `Parameters` represents a sequence of parameters.
/// 
public struct Parameters: Equatable, CustomStringConvertible {
  private let params: [Parameter]
  
  /// Constructor.
  public init(_ params: [Parameter] = []) {
    self.params = params
  }
  
  /// Returns the total number of parameters.
  public var parameterCount: Int {
    return self.params.count
  }
  
  /// Returns true iff the parameter at `index` was specified (i.e. it was specified
  /// and it is not `none`).
  public func parameterProvided(_ index: Int) -> Bool {
    return index >= 0 && index < self.params.count && self.params[index] != .none
  }
  
  /// Returns the parameter at `index`.
  public func parameter(_ index: Int) -> Parameter? {
    if index >= 0 && index < self.params.count {
      return self.params[index]
    } else {
      return nil
    }
  }
  
  /// Returns the `index`-th parameter as a number; throws an error if the parameter
  /// is not a number. Returns `nil` if the parameter was not provided.
  public func number(_ index: Int, allowNegative: Bool = false) throws -> Int? {
    if index >= 0 && index < self.params.count {
      switch self.params[index] {
        case .none:
          return nil
        case .number(let n):
          if n < 0 && !allowNegative {
            throw CLFormatError.expectedPositiveNumberParameter(index, n)
          }
          return n
        default:
          throw CLFormatError.expectedNumberParameter(index, self.params[index])
      }
    } else {
      return nil
    }
  }
  
  /// Returns the `index`-th parameter as a character; throws an error if the parameter
  /// is not a character. Returns `nil` if the parameter was not provided.
  public func character(_ index: Int) throws -> Character? {
    if index >= 0 && index < self.params.count {
      switch self.params[index] {
        case .none:
          return nil
        case .character(let ch):
          return ch
        default:
          throw CLFormatError.expectedCharacterParameter(index, self.params[index])
      }
    } else {
      return nil
    }
  }
  
  /// Creates a new set of parameters by expanding `nextArgument` and
  /// `remainingArguments` parameters for a given list of arguments.
  public func process(arguments: Arguments) throws -> Parameters {
    var params = [Parameter]()
    for param in self.params {
      switch param {
        case .nextArgument:
          params.append(try arguments.nextAsParameter())
        case .remainingArguments:
          params.append(.number(arguments.left))
        default:
          params.append(param)
      }
    }
    return Parameters(params)
  }
  
  /// Returns a description of the parameters in a syntax compatible with
  /// the control language.
  public var description: String {
    var (res, sep) = ("", "")
    for param in self.params {
      res += "\(sep)\(param)"
      sep = ","
    }
    return res
  }
}

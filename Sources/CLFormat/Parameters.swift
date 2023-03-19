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

public enum Parameter: Equatable, CustomStringConvertible {
  case none
  case nextArgument
  case remainingArguments
  case number(Int)
  case character(Character)
  
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

public struct Parameters: Equatable, CustomStringConvertible {
  private let params: [Parameter]
  
  public init(_ params: [Parameter] = []) {
    self.params = params
  }
  
  public var parameterCount: Int {
    return self.params.count
  }
  
  public func parameterProvided(_ index: Int) -> Bool {
    return index >= 0 && index < self.params.count && self.params[index] != .none
  }
  
  public func parameter(_ index: Int) -> Parameter? {
    if index >= 0 && index < self.params.count {
      return self.params[index]
    } else {
      return nil
    }
  }
  
  public func number(_ index: Int, default d: Int? = nil, allowNegative: Bool = false) throws -> Int {
    if index >= 0 && index < self.params.count {
      guard case .number(let n) = self.params[index] else {
        if case .none = self.params[index], let def = d {
          return def
        }
        throw CLFormatError.expectedNumberParameter(index, self.params[index])
      }
      if n < 0 && !allowNegative {
        throw CLFormatError.expectedPositiveNumberParameter(index, n)
      }
      return n
    } else if let def = d {
      return def
    } else {
      throw CLFormatError.missingNumberParameter(index)
    }
  }
  
  public func character(_ index: Int, default d: Character? = nil) throws -> Character {
    if index >= 0 && index < self.params.count {
      guard case .character(let ch) = self.params[index] else {
        if case .none = self.params[index], let def = d {
          return def
        }
        throw CLFormatError.expectedCharacterParameter(index, self.params[index])
      }
      return ch
    } else if let def = d {
      return def
    } else {
      throw CLFormatError.missingCharacterParameter(index)
    }
  }
  
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
  
  public var description: String {
    var (res, sep) = ("", "")
    for param in self.params {
      res += "\(sep)\(param)"
      sep = ","
    }
    return res
  }
}

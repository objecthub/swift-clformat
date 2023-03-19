//
//  Modifiers.swift
//  CLFormat
//
//  Created by Matthias Zenger on 13/03/2023.
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
/// Option set `Modifiers` implements the three available format directive
/// modifiers: `colon`, `at`, and `plus`. `plus` is CLFormat-specific and not
/// available in the original Common Lisp implementation.
/// 
public struct Modifiers: OptionSet, CustomStringConvertible {
  public let rawValue: Int
  public static let colon = Modifiers(rawValue: 1 << 0)
  public static let at = Modifiers(rawValue: 1 << 1)
  public static let plus = Modifiers(rawValue: 1 << 2)
  
  /// Constructor.
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  /// Returns a string representation of the modifiers in the syntax used
  /// by control strings.
  public var description: String {
    var res = ""
    if self.contains(.colon) {
      res += ":"
    }
    if self.contains(.at) {
      res += "@"
    }
    if self.contains(.plus) {
      res += "+"
    }
    return res
  }
}

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

struct Modifiers: OptionSet, CustomStringConvertible {
  let rawValue: Int
  static let colon = Modifiers(rawValue: 1 << 0)
  static let at = Modifiers(rawValue: 1 << 1)
  static let plus = Modifiers(rawValue: 1 << 2)
  
  var description: String {
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

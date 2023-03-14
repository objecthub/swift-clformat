//
//  Number.swift
//  CLFormat
//
//  Created by Matthias Zenger on 06/03/2023.
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
/// Enumeration `Number` is used to bundle different numeric datatypes into a single
/// wrapper. `Number` can be instaniated using any numeric type. It also acts as a
/// factory for `NSNumber` instances. Finally, enumeration `Number` implements a few
/// features needed for `CLFormat`.
/// 
public enum Number: Equatable, Codable, CustomStringConvertible {
  case int(Int)
  case int16(Int16)
  case int32(Int32)
  case int64(Int64)
  case uint(UInt)
  case uint8(UInt8)
  case uint16(UInt16)
  case uint32(UInt32)
  case uint64(UInt64)
  case float(Float)
  case double(Double)
  case decimal(Decimal)
  
  public init?(_ arg: Any) {
    if let num = arg as? Int {
      self = .int(num)
    } else if let num = arg as? Int64 {
      self = .int64(num)
    } else if let num = arg as? UInt {
      self = .uint(num)
    } else if let num = arg as? UInt64 {
      self = .uint64(num)
    } else if let num = arg as? Int16 {
      self = .int16(num)
    } else if let num = arg as? Int32 {
      self = .int32(num)
    } else if let num = arg as? UInt8 {
      self = .uint8(num)
    } else if let num = arg as? UInt16 {
      self = .uint16(num)
    } else if let num = arg as? UInt32 {
      self = .uint32(num)
    } else if let num = arg as? Float {
      self = .float(num)
    } else if let num = arg as? Double {
      self = .double(num)
    } else if let num = arg as? Decimal {
      self = .decimal(num)
    } else if let num = arg as? NSDecimalNumber {
      self = .decimal(num as Decimal)
    } else {
      return nil
    }
  }
  
  public var isInteger: Bool {
    return !self.isFloatingPointNumber
  }
  
  public var isUnsignedInteger: Bool {
    switch self {
      case .uint(_), .uint8(_), .uint16(_), .uint32(_), .uint64(_):
        return true
      default:
        return false
    }
  }
  
  public var isFloatingPointNumber: Bool {
    switch self {
      case .float(_), .double(_), .decimal(_):
        return true
      default:
        return false
    }
  }
  
  public func equals(integer i: Int) -> Bool {
    switch self {
      case .int(let num):
        return num == i
      case .int16(let num):
        return num == i
      case .int32(let num):
        return num == i
      case .int64(let num):
        return num == i
      case .uint(let num):
        return num == i
      case .uint8(let num):
        return num == i
      case .uint16(let num):
        return num == i
      case .uint32(let num):
        return num == i
      case .uint64(let num):
        return num == i
      case .float(_):
        return false
      case .double(_):
        return false
      case .decimal(_):
        return false
    }
  }
  
  public var romanNumeral: String {
    switch self {
      case .int(let num):
        return Number.romanNumeral(for: num) ?? num.description
      case .int16(let num):
        if let num = Int(exactly: num) {
          return Number.romanNumeral(for: num) ?? num.description
        } else {
          return num.description
        }
      case .int32(let num):
        if let num = Int(exactly: num) {
          return Number.romanNumeral(for: num) ?? num.description
        } else {
          return num.description
        }
      case .int64(let num):
        if let num = Int(exactly: num) {
          return Number.romanNumeral(for: num) ?? num.description
        } else {
          return num.description
        }
      case .uint(let num):
        if let num = Int(exactly: num) {
          return Number.romanNumeral(for: num) ?? num.description
        } else {
          return num.description
        }
      case .uint8(let num):
        if let num = Int(exactly: num) {
          return Number.romanNumeral(for: num) ?? num.description
        } else {
          return num.description
        }
      case .uint16(let num):
        if let num = Int(exactly: num) {
          return Number.romanNumeral(for: num) ?? num.description
        } else {
          return num.description
        }
      case .uint32(let num):
        if let num = Int(exactly: num) {
          return Number.romanNumeral(for: num) ?? num.description
        } else {
          return num.description
        }
      case .uint64(let num):
        if let num = Int(exactly: num) {
          return Number.romanNumeral(for: num) ?? num.description
        } else {
          return num.description
        }
      case .float(let num):
        return num.description
      case .double(let num):
        return num.description
      case .decimal(let num):
        return num.description
    }
  }
  
  private static func romanNumeral(for n: Int) -> String? {
    guard n > 0 && n < 4000 else {
      return nil
    }
    var res = ""
    let table = [(1000, "M"), (900, "CM"), (500, "D"), (400, "CD"),
                 (100, "C"), (90, "XC"), (50, "L"), (40, "XL"),
                 (10, "X"), (9, "IX"), (5, "V"), (4, "IV"),
                 (1, "I")]
    var num = n
    for (ar, rome) in table {
      let repeats = num / ar
      res += String(repeating: rome, count: repeats)
      num = num % ar
    }
    return res
  }
  
  public var nsnumber: NSNumber {
    switch self {
      case .int(let num):
        return NSNumber(value: num)
      case .int16(let num):
        return NSNumber(value: num)
      case .int32(let num):
        return NSNumber(value: num)
      case .int64(let num):
        return NSNumber(value: num)
      case .uint(let num):
        return NSNumber(value: num)
      case .uint8(let num):
        return NSNumber(value: num)
      case .uint16(let num):
        return NSNumber(value: num)
      case .uint32(let num):
        return NSNumber(value: num)
      case .uint64(let num):
        return NSNumber(value: num)
      case .float(let num):
        return NSNumber(value: num)
      case .double(let num):
        return NSNumber(value: num)
      case .decimal(let num):
        return NSDecimalNumber(decimal: num)
    }
  }
  
  public var description: String {
    switch self {
      case .int(let num):
        return String(num)
      case .int16(let num):
        return String(num)
      case .int32(let num):
        return String(num)
      case .int64(let num):
        return String(num)
      case .uint(let num):
        return String(num)
      case .uint8(let num):
        return String(num)
      case .uint16(let num):
        return String(num)
      case .uint32(let num):
        return String(num)
      case .uint64(let num):
        return String(num)
      case .float(let num):
        return String(num)
      case .double(let num):
        return String(num)
      case .decimal(let num):
        return num.description
    }
  }
}

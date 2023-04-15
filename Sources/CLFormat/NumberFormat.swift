//
//  NumberFormat.swift
//  CLFormat
//
//  Created by Matthias Zenger on 12/03/2023.
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
/// `NumberFormat` provides a few static methods for formatting numbers.
/// 
public struct NumberFormat {
  public static let defaultLocale = Locale(identifier: "en_US")
  public static let currentLocale = Locale.current
  
  /// Format money amounts.
  public static func format(_ number: Number,
                            fractionDigits: Int,
                            minIntegerDigits: Int,
                            minWidth: Int,
                            padchar: Character,
                            curchar: Character?,
                            groupsep: Character?,
                            groupsize: Int?,
                            locale: Locale?,
                            uselocale: Bool,
                            usegroup: Bool,
                            forcesign: Bool,
                            signBeforePad: Bool) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = uselocale || curchar != nil ? .currency : .decimal
    formatter.minimumFractionDigits = fractionDigits
    formatter.maximumFractionDigits = fractionDigits
    formatter.minimumIntegerDigits = minIntegerDigits
    if uselocale {
      formatter.locale = locale ?? NumberFormat.defaultLocale
    } else if curchar != nil {
      formatter.locale = NumberFormat.defaultLocale
    }
    if let curchar = curchar {
      formatter.currencySymbol = String(curchar)
    }
    if let groupsep = groupsep {
      formatter.groupingSeparator = String(groupsep)
      formatter.currencyGroupingSeparator = String(groupsep)
    }
    if let groupsize = groupsize {
      formatter.groupingSize = groupsize
      if groupsep == nil && !uselocale && curchar == nil {
        formatter.groupingSeparator = ","
        formatter.currencyGroupingSeparator = ","
      }
    }
    formatter.usesGroupingSeparator = usegroup
    if forcesign {
      formatter.positivePrefix = formatter.plusSign
    }
    if minWidth > 1 {
      formatter.formatWidth = minWidth
      formatter.paddingCharacter = String(padchar)
      formatter.paddingPosition = signBeforePad ? .afterPrefix : .beforePrefix
    }
    let str = formatter.string(from: number.nsnumber) ?? number.description
    return str
  }
  
  /// Format floating-point numbers in scientific style.
  public static func format(_ number: Number,
                            width: Int?,
                            padchar: Character,
                            overflowchar: Character?,
                            exponentchar: Character?,
                            fractionDigits: Int?,
                            exponentDigits: Int?,
                            scaleFactor: Int,
                            locale: Locale?,
                            uselocale: Bool,
                            forcesign: Bool) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .scientific
    formatter.usesSignificantDigits = false
    if scaleFactor > 0 {
      let fDigits = fractionDigits ?? (scaleFactor - 1)
      let intDigits = min(fDigits + 1, scaleFactor)
      if fractionDigits == nil {
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 100
      } else {
        formatter.minimumFractionDigits = fDigits + 1 - intDigits
        formatter.maximumFractionDigits = fDigits + 1 - intDigits
      }
      formatter.minimumIntegerDigits = intDigits
      formatter.maximumIntegerDigits = intDigits
      if forcesign {
        formatter.positivePrefix = formatter.plusSign
      }
    } else {
      let fDigits = fractionDigits ?? (1 - scaleFactor)
      let intDigits = -max(1 - fDigits, scaleFactor)
      if fractionDigits == nil {
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 100
      } else {
        formatter.minimumFractionDigits = fDigits - intDigits
        formatter.maximumFractionDigits = fDigits - intDigits
      }
      formatter.minimumIntegerDigits = 0
      formatter.maximumIntegerDigits = 0
      formatter.multiplier = NSNumber(value: pow(10.0, Double(intDigits)))
      formatter.decimalSeparator = "." + String(repeating: "0", count: intDigits)
      if forcesign {
        formatter.negativePrefix = formatter.minusSign + "0"
        formatter.positivePrefix = formatter.plusSign + "0"
      } else {
        formatter.negativePrefix = formatter.minusSign + "0"
        formatter.positivePrefix = "0"
      }
    }
    formatter.exponentSymbol = "|"
    if let locale = locale {
      formatter.locale = locale
    }
    formatter.localizesFormat = uselocale
    formatter.usesGroupingSeparator = false
    var str = formatter.string(from: number.nsnumber) ?? number.description
    let comp = str.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: true)
    if let exponentDigits = exponentDigits {
      if comp.count == 2, let exp = Int(comp[1]) {
        let padding = String(repeating: "0",
                             count: exponentDigits - comp[1].count + (exp < 0 ? 1 : 0))
        str = "\(comp[0])\(exponentchar ?? "E")\(exp >= 0 ? "+" : "-")\(padding)\(abs(exp))"
      } else if comp.count == 1 {
        let padding = String(repeating: "0", count: exponentDigits)
        str = "\(str)\(exponentchar ?? "E")+\(padding)"
      }
    } else if comp.count == 2, let fst = comp[1].first {
      str = "\(comp[0])\(exponentchar ?? "E")\(fst == "-" ? "" : "+")\(comp[1])"
    }
    if let width = width, width > 1 {
      if str.count > width, let overflowchar = overflowchar {
        return String(repeating: overflowchar, count: width)
      } else if str.count < width {
        return String(repeating: padchar, count: width - str.count) + str
      }
    }
    return str
  }
  
  /// Format floating-point numbers in decimal style
  public static func format(_ number: Number,
                            width: Int?,
                            padchar: Character,
                            overflowchar: Character?,
                            fractionDigits: Int?,
                            exp: Int,
                            groupsep: Character?,
                            groupsize: Int?,
                            locale: Locale?,
                            usegroup: Bool,
                            uselocale: Bool,
                            forcesign: Bool) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumIntegerDigits = 1
    if let fractionDigits = fractionDigits {
      formatter.minimumFractionDigits = fractionDigits
      formatter.maximumFractionDigits = fractionDigits
    } else {
      formatter.minimumFractionDigits = 1
      if let width = width, width > 1, exp >= -100, exp <= 100 {
        let num = number.asDouble
        let intDigits = num.isZero ? 1.0 : max(ceil(log10(num * pow(10.0, Double(exp)))), 1.0)
        formatter.maximumFractionDigits = width - Int(intDigits) - 1
      } else {
        formatter.maximumFractionDigits = (width ?? 100) - 2
      }
    }
    if uselocale {
      formatter.locale = locale ?? NumberFormat.defaultLocale
      formatter.localizesFormat = true
    } else if usegroup {
      formatter.locale = NumberFormat.defaultLocale
    }
    if let groupsep = groupsep {
      formatter.groupingSeparator = String(groupsep)
    }
    if let groupsize = groupsize {
      formatter.groupingSize = groupsize
    }
    formatter.usesGroupingSeparator = usegroup
    if forcesign {
      formatter.positivePrefix = formatter.plusSign
    }
    if exp >= -100 && exp <= 100 {
      formatter.multiplier = NSNumber(value: pow(10.0, Double(exp)))
    }
    if let width = width, width > 1 {
      formatter.formatWidth = width
      formatter.paddingCharacter = String(padchar)
      formatter.paddingPosition = .beforePrefix
    }
    let str = formatter.string(from: number.nsnumber) ?? number.description
    if let width = width, width > 1, str.count > width, let overflowchar = overflowchar {
      return String(repeating: overflowchar, count: width)
    }
    return str
  }
  
  /// Format an integer number using the given style.
  public static func format(_ number: Number,
                            style: NumberFormatter.Style,
                            mincol: Int,
                            padchar: Character,
                            groupsep: Character?,
                            groupsize: Int?,
                            locale: Locale?,
                            usegroup: Bool,
                            uselocale: Bool,
                            forcesign: Bool) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = style
    if let locale = locale {
      formatter.locale = locale
    }
    if style == .decimal {
      formatter.localizesFormat = uselocale
    }
    if let groupsep = groupsep {
      formatter.groupingSeparator = String(groupsep)
    }
    if let groupsize = groupsize {
      formatter.groupingSize = groupsize
    }
    if !uselocale {
      formatter.usesGroupingSeparator = usegroup
    }
    var str = formatter.string(from: number.nsnumber) ?? number.description
    if forcesign && !str.starts(with: "-") {
      str = "+" + str
    }
    if str.count < mincol {
      return String(repeating: padchar, count: mincol - str.count) + str
    } else {
      return str
    }
  }
  
  /// Format integers using a given radix.
  public static func format(_ number: Number,
                            radix: Int,
                            mincol: Int,
                            padchar: Character,
                            groupsep: Character,
                            groupsize: Int,
                            usegroup: Bool,
                            forcesign: Bool,
                            uppercase: Bool,
                            force: Bool) -> String? {
    var str: String
    var float: Bool = false
    switch number {
      case .int(let num):
        str = String(num, radix: radix, uppercase: uppercase)
      case .int16(let num):
        str = String(num, radix: radix, uppercase: uppercase)
      case .int32(let num):
        str = String(num, radix: radix, uppercase: uppercase)
      case .int64(let num):
        str = String(num, radix: radix, uppercase: uppercase)
      case .uint(let num):
        str = String(num, radix: radix, uppercase: uppercase)
      case .uint8(let num):
        str = String(num, radix: radix, uppercase: uppercase)
      case .uint16(let num):
        str = String(num, radix: radix, uppercase: uppercase)
      case .uint32(let num):
        str = String(num, radix: radix, uppercase: uppercase)
      case .uint64(let num):
        str = String(num, radix: radix, uppercase: uppercase)
      default:
        float = true
        if force {
          str = number.description
        } else {
          return nil
        }
    }
    if usegroup && !float {
      var index = str.endIndex
      while index > str.startIndex {
        if let i = str.index(index, offsetBy: -groupsize, limitedBy: str.startIndex) {
          str.insert(groupsep, at: i)
          index = i
        } else {
          break
        }
      }
      while let ch = str.first, ch == groupsep {
        str.remove(at: str.startIndex)
      }
    }
    if forcesign && !float && !str.starts(with: "-") {
      str = "+" + str
    }
    if str.count < mincol {
      return String(repeating: padchar, count: mincol - str.count) + str
    } else {
      return str
    }
  }
}

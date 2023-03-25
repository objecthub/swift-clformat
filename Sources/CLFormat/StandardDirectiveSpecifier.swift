//
//  Directives.swift
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

public enum StandardDirectiveSpecifier: DirectiveSpecifier {
  case ascii
  case write
  case sexpr
  case decimal
  case radix
  case binary
  case octal
  case hexadecimal
  case character
  case fixedFloat
  case exponentFloat
  case generalFloat
  case moneyAmount
  case percent
  case ampersand
  case bar
  case tilde
  case plural
  case tabular
  case ignoreArgs
  case upAndOut
  case conversion(CLControl)
  case conversionEnd
  case conditional([CLControl], Bool)
  case conditionalEnd
  case separator
  case iteration(CLControl)
  case iterationEnd
  case justification([CLControl], Int?, Int?)
  case justificationEnd
  case indirection
  
  public var identifier: Character {
    switch self {
      case .ascii:
        return "A"
      case .write:
        return "W"
      case .sexpr:
        return "S"
      case .decimal:
        return "D"
      case .radix:
        return "R"
      case .binary:
        return "B"
      case .octal:
        return "O"
      case .hexadecimal:
        return "X"
      case .character:
        return "C"
      case .fixedFloat:
        return "F"
      case .exponentFloat:
        return "E"
      case .generalFloat:
        return "G"
      case .moneyAmount:
        return "$"
      case .percent:
        return "%"
      case .ampersand:
        return "&"
      case .bar:
        return "|"
      case .tilde:
        return "~"
      case .plural:
        return "P"
      case .tabular:
        return "T"
      case .ignoreArgs:
        return "*"
      case .upAndOut:
        return "^"
      case .conversion(_):
        return "("
      case .conversionEnd:
        return ")"
      case .conditional(_, _):
        return "["
      case .conditionalEnd:
        return "]"
      case .separator:
        return ";"
      case .iteration(_):
        return "{"
      case .iterationEnd:
        return "}"
      case .justification(_, _, _):
        return "<"
      case .justificationEnd:
        return ">"
      case .indirection:
        return "?"
    }
  }
  
  public func apply(context: Context,
                    parameters: Parameters,
                    modifiers: Modifiers,
                    arguments: Arguments) throws -> Instruction {
    switch self {
      case .ascii:
        let str: String
        if let arg = try arguments.next() {
          if modifiers.contains(.colon), let x = arg as? DebugCLFormatConvertible {
            str = x.clformatDebugDescription
          } else if modifiers.contains(.colon), let x = arg as? CustomDebugStringConvertible {
            str = x.debugDescription
          } else if let x = arg as? CLFormatConvertible {
            str = x.clformatDescription
          } else if let x = arg as? CustomStringConvertible {
            str = x.description
          } else {
            str = "\(arg)"
          }
        } else {
          str = "nil"
        }
        return .append(self.pad(string: str,
                                left: modifiers.contains(.at),
                                right: !modifiers.contains(.at),
                                padchar: try parameters.character(3) ?? " ",
                                ellipsis: try parameters.character(5) ?? "…",
                                mincol: try parameters.number(0) ?? 0,
                                colinc: try parameters.number(1) ?? 1,
                                minpad: try parameters.number(2) ?? 0,
                                maxcol: try parameters.number(4)))
      case .write:
        let str: String
        if let arg = try arguments.next() {
          if modifiers.contains(.colon), let x = arg as? CustomDebugStringConvertible {
            str = x.debugDescription
          } else if let x = arg as? CustomStringConvertible {
            str = x.description
          } else {
            str = "\(arg)"
          }
        } else {
          str = "nil"
        }
        return .append(self.pad(string: str,
                                left: modifiers.contains(.at),
                                right: !modifiers.contains(.at),
                                padchar: try parameters.character(3) ?? " ",
                                ellipsis: try parameters.character(5) ?? "…",
                                mincol: try parameters.number(0) ?? 0,
                                colinc: try parameters.number(1) ?? 1,
                                minpad: try parameters.number(2) ?? 0,
                                maxcol: try parameters.number(4)))
      case .sexpr:
        let str: String
        if let arg = try arguments.next() {
          if let x = arg as? String {
            str = "\"\(x)\""
          } else if let x = arg as? NSMutableString {
            str = "\"\(x as String)\""
          } else if let x = arg as? NSString {
            str = "\"\(x as String)\""
          } else if let x = arg as? Character {
            str = "'\(x)'"
          } else if modifiers.contains(.colon), let x = arg as? DebugCLFormatConvertible {
            str = x.clformatDebugDescription
          } else if modifiers.contains(.colon), let x = arg as? CustomDebugStringConvertible {
            str = x.debugDescription
          } else if let x = arg as? CLFormatConvertible {
            str = x.clformatDescription
          } else if let x = arg as? CustomStringConvertible {
            str = x.description
          } else {
            str = "\(arg)"
          }
        } else {
          str = "nil"
        }
        return .append(self.pad(string: str,
                                left: modifiers.contains(.at),
                                right: !modifiers.contains(.at),
                                padchar: try parameters.character(3) ?? " ",
                                ellipsis: try parameters.character(5) ?? "…",
                                mincol: try parameters.number(0) ?? 0,
                                colinc: try parameters.number(1) ?? 1,
                                minpad: try parameters.number(2) ?? 0,
                                maxcol: try parameters.number(4)))
      case .decimal:
        return .append(NumberFormat.format(
                         try arguments.nextAsNumber(),
                         style: .decimal,
                         mincol: try parameters.number(0) ?? 0,
                         padchar: try parameters.character(1) ?? " ",
                         groupsep: try parameters.character(2),
                         groupsize: try parameters.number(3),
                         locale: arguments.locale,
                         usegroup: modifiers.contains(.colon),
                         uselocale: modifiers.contains(.plus),
                         forcesign: modifiers.contains(.at)))
      case .radix:
        let number = try arguments.nextAsNumber()
        let radix = try parameters.number(0) ?? 10
        if parameters.parameterCount == 0 {
          if !modifiers.contains(.colon) && !modifiers.contains(.at) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            if let locale = arguments.locale {
              formatter.locale = locale
            } else if !modifiers.contains(.plus) {
              formatter.locale = Locale(identifier: "en_US")
            }
            return .append(formatter.string(from: number.nsnumber) ??
                           String(describing: number.nsnumber))
          } else if modifiers.contains(.colon) && !modifiers.contains(.at) {
            return .append(NumberFormat.format(
                             number,
                             style: .ordinal,
                             mincol: 0,
                             padchar: " ",
                             groupsep: nil,
                             groupsize: nil,
                             locale: arguments.locale,
                             usegroup: false,
                             uselocale: false,
                             forcesign: false))
          } else if !modifiers.contains(.colon) && modifiers.contains(.at) {
            return .append(number.romanNumeral)
          } else {
            throw CLFormatError.unsupportedDirective("~:@R")
          }
        } else if radix == 10 {
          let str = NumberFormat.format(
                      number,
                      style: .decimal,
                      mincol: try parameters.number(1) ?? 0,
                      padchar: try parameters.character(2) ?? " ",
                      groupsep: try parameters.character(3),
                      groupsize: try parameters.number(4),
                      locale: arguments.locale,
                      usegroup: modifiers.contains(.colon),
                      uselocale: modifiers.contains(.plus),
                      forcesign: modifiers.contains(.at))
          return .append(str)
        } else if let str = NumberFormat.format(
                              number,
                              radix: radix,
                              mincol: try parameters.number(1) ?? 0,
                              padchar: try parameters.character(2) ?? " ",
                              groupsep: try parameters.character(3) ?? ",",
                              groupsize: try parameters.number(4) ?? 3,
                              usegroup: modifiers.contains(.colon),
                              forcesign: modifiers.contains(.at),
                              uppercase: modifiers.contains(.plus),
                              force: true) {
          return .append(str)
        } else {
          throw CLFormatError.cannotRepresentNumber(number, radix)
        }
      case .binary:
        let number = try arguments.nextAsNumber()
        if let str = NumberFormat.format(
                       number,
                       radix: 2,
                       mincol: try parameters.number(0) ?? 0,
                       padchar: try parameters.character(1) ?? " ",
                       groupsep: try parameters.character(2) ?? " ",
                       groupsize: try parameters.number(3) ?? 4,
                       usegroup: modifiers.contains(.colon),
                       forcesign: modifiers.contains(.at),
                       uppercase: modifiers.contains(.plus),
                       force: true) {
          return .append(str)
        } else {
          throw CLFormatError.cannotRepresentNumber(number, 2)
        }
      case .octal:
        let number = try arguments.nextAsNumber()
        if let str = NumberFormat.format(
                       number,
                       radix: 8,
                       mincol: try parameters.number(0) ?? 0,
                       padchar: try parameters.character(1) ?? " ",
                       groupsep: try parameters.character(2) ?? " ",
                       groupsize: try parameters.number(3) ?? 4,
                       usegroup: modifiers.contains(.colon),
                       forcesign: modifiers.contains(.at),
                       uppercase: modifiers.contains(.plus),
                       force: true) {
          return .append(str)
        } else {
          throw CLFormatError.cannotRepresentNumber(number, 8)
        }
      case .hexadecimal:
        let number = try arguments.nextAsNumber()
        if let str = NumberFormat.format(
                       number,
                       radix: 16,
                       mincol: try parameters.number(0) ?? 0,
                       padchar: try parameters.character(1) ?? " ",
                       groupsep: try parameters.character(2) ?? ":",
                       groupsize: try parameters.number(3) ?? 2,
                       usegroup: modifiers.contains(.colon),
                       forcesign: modifiers.contains(.at),
                       uppercase: modifiers.contains(.plus),
                       force: true) {
          return .append(str)
        } else {
          throw CLFormatError.cannotRepresentNumber(number, 16)
        }
      case .character:
        let char = try arguments.nextAsCharacter()
        let str = String(char)
        // Print in XML encoding
        if modifiers.contains(.plus) {
          if modifiers.contains(.colon) {
            return .append(str.applyingTransform(.init("Any-Hex/Unicode"), reverse: false) ?? str)
          } else {
            return .append(str.applyingTransform(.toXMLHex, reverse: false) ?? str)
          }
        // Swift character literal format
        } else if modifiers.contains(.at) {
          if modifiers.contains(.colon) {
            return .append("\"\(str.applyingTransform(.init("Any-Hex"), reverse: false) ?? str)\"")
          } else {
            return .append("\"\(str.applyingTransform(.toUnicodeName, reverse: false) ?? str)\"")
          }
        // Pretty print as unicode scalar names
        } else if modifiers.contains(.colon) {
          return .append(str.flatMap(\.unicodeScalars).compactMap(\.properties.name)
                            .joined(separator: ", "))
        // Just the character
        } else {
          return .append("\(char)")
        }
      case .fixedFloat:
        let w = try parameters.number(0) ?? Int.min
        let d = try parameters.number(1) ?? Int.min
        let k = try parameters.number(2, allowNegative: true) ?? 0
        let oc = try parameters.character(3)
        let pc = try parameters.character(4) ?? " "
        let number = try arguments.nextAsNumber()
        return .append(NumberFormat.format(number,
                                           width: w == Int.min ? nil : w,
                                           padchar: pc,
                                           overflowchar: oc,
                                           fractionDigits: d == Int.min ? nil : d,
                                           exponent: k,
                                           groupsep: try parameters.character(5),
                                           groupsize: try parameters.number(6),
                                           locale: arguments.locale,
                                           usegroup: modifiers.contains(.colon),
                                           uselocale: modifiers.contains(.plus),
                                           forcesign: modifiers.contains(.at)))
      case .exponentFloat:
        let w = try parameters.number(0) ?? Int.min
        let d = try parameters.number(1) ?? Int.min
        let e = try parameters.number(2) ?? Int.min
        let k = try parameters.number(3, allowNegative: true) ?? 1
        let oc = try parameters.character(4)
        let pc = try parameters.character(5) ?? " "
        let ec = try parameters.character(6) ?? "E"
        let number = try arguments.nextAsNumber()
        return .append(NumberFormat.format(number,
                                           width: w == Int.min ? nil : w,
                                           padchar: pc,
                                           overflowchar: oc,
                                           exponentchar: ec,
                                           fractionDigits: d == Int.min ? nil : d,
                                           exponentDigits: e == Int.min ? nil : e,
                                           scaleFactor: k,
                                           locale: arguments.locale,
                                           uselocale: modifiers.contains(.plus),
                                           forcesign: modifiers.contains(.at)))
      case .generalFloat:
        let w = try parameters.number(0) ?? Int.min
        let d = try parameters.number(1) ?? Int.min
        let e = try parameters.number(2) ?? Int.min
        let k = try parameters.number(3, allowNegative: true) ?? 1
        let oc = try parameters.character(4)
        let pc = try parameters.character(5) ?? " "
        let ec = try parameters.character(6) ?? "E"
        let number = try arguments.nextAsNumber()
        let arg = number.nsnumber.doubleValue
        let n = arg.isZero ? 0 : Int(floor(log10(arg))) + 1
        let ee = e == Int.min ? 4 : e + 2
        let ww = w == Int.min ? Int.min : w - ee
        let nd = d == Int.min ? max("\(arg)".count, min(n, 7)) : d
        // print("n = \(n), ee = \(ee), ww = \(ww), nd = \(nd)")
        let dd = {
          if d == Int.min {
            let q = "\(arg)".count
            // print("q = \(q), n = \(n), str = \"\(arg)\"")
            return max(q, min(n, 7)) - n - 1
          } else {
            return d - n
          }
        }()
        if dd >= 0 && dd <= nd {
          return .append(NumberFormat.format(number,
                                             width: ww == Int.min ? nil : ww,
                                             padchar: pc,
                                             overflowchar: oc,
                                             fractionDigits: dd,
                                             exponent: 0,
                                             groupsep: nil,
                                             groupsize: nil,
                                             locale: arguments.locale,
                                             usegroup: modifiers.contains(.colon),
                                             uselocale: modifiers.contains(.plus),
                                             forcesign: modifiers.contains(.at)) +
                         String(repeating: " ", count: ee))
        } else {
          return .append(NumberFormat.format(number,
                                             width: w == Int.min ? nil : w,
                                             padchar: pc,
                                             overflowchar: oc,
                                             exponentchar: ec,
                                             fractionDigits: d == Int.min ? nil : d,
                                             exponentDigits: e == Int.min ? nil : e,
                                             scaleFactor: k,
                                             locale: arguments.locale,
                                             uselocale: modifiers.contains(.plus),
                                             forcesign: modifiers.contains(.at)))
        }
      case .moneyAmount:
        let number = try arguments.nextAsNumber()
        return .append(NumberFormat.format(
                         number,
                         fractionDigits: try parameters.number(0) ?? 2,
                         minIntegerDigits: try parameters.number(1) ?? 1,
                         minWidth: try parameters.number(2) ?? 0,
                         padchar: try parameters.character(3) ?? " ",
                         curchar: try parameters.character(4),
                         groupsep: try parameters.character(5),
                         groupsize: try parameters.number(6),
                         locale: arguments.locale,
                         uselocale: modifiers.contains(.plus),
                         usegroup: parameters.parameterProvided(5) ||
                                   parameters.parameterProvided(6),
                         forcesign: modifiers.contains(.at),
                         signBeforePad: modifiers.contains(.colon)))
      case .percent:
        return .append(String(repeating: "\n", count: try parameters.number(0) ?? 1))
      case .ampersand:
        var n = try parameters.number(0) ?? 1
        if let last = context.current.last, last == "\n" {
          n -= 1
        }
        return .append(n > 0 ? String(repeating: "\n", count: n) : "")
      case .bar:
        return .append(String(repeating: "\u{12}", count: try parameters.number(0) ?? 1))
      case .tilde:
        return .append(String(repeating: "~", count: try parameters.number(0) ?? 1))
      case .plural:
        // Back up first
        if modifiers.contains(.colon) {
          try arguments.advance(by: -1)
        }
        // Return plural forms
        let number = try arguments.nextAsNumber()
        if modifiers.contains(.at) {
          return .append(number.equals(integer: 1) ? "y" : "ies")
        } else {
          return .append(number.equals(integer: 1) ? "" : "s")
        }
      case .tabular:
        let col = context.current.currentColumn(tabsize: arguments.tabsize)
        let colnum = try parameters.number(0) ?? 1
        let colinc = try parameters.number(1) ?? 1
        if modifiers.contains(.at) {
          if colinc > 0 && (col + colnum) % colinc > 0 {
            return .append(String(repeating: " ",
                                  count: colnum + (colinc - ((col + colnum) % colinc))))
          } else {
            return .append(String(repeating: " ", count: colnum))
          }
        } else {
          if col < colnum {
            return .append(String(repeating: " ", count: colnum - col))
          } else if colinc > 0 {
            return .append(String(repeating: " ", count: colinc - ((col - colnum) % colinc)))
          } else {
            return .append("")
          }
        }
      case .ignoreArgs:
        // Absolute jump
        if modifiers.contains(.at) && !modifiers.contains(.colon) {
          try arguments.jump(to: parameters.number(0) ?? 0)
        // Go backwards
        } else if modifiers.contains(.colon) && !modifiers.contains(.at) {
          try arguments.advance(by: -(parameters.number(0) ?? 1))
        // Go forward
        } else if !modifiers.contains(.colon) && !modifiers.contains(.at) {
          try arguments.advance(by: parameters.number(0) ?? 1)
        // Illegal
        } else {
          throw CLFormatError.malformedDirective("~\(parameters)\(modifiers)*")
        }
        return .append("")
      case .upAndOut:
        if modifiers.contains(.colon) && parameters.parameterCount == 0 {
          if arguments.numArgumentsLeft == 0 {
            return .break("")
          }
        } else if parameters.parameterCount < 2 {
          if (try parameters.number(0) ?? arguments.left) == 0 {
            return modifiers.contains(.colon) ? .break("") : .continue("")
          }
        } else if parameters.parameterCount == 2 {
          if parameters.parameter(0)! == parameters.parameter(1)! {
            return modifiers.contains(.colon) ? .break("") : .continue("")
          }
        } else if parameters.parameterCount == 3 {
          guard let fst = try parameters.number(0),
                let snd = try parameters.number(1),
                let trd = try parameters.number(2) else {
            throw CLFormatError.malformedDirective("~\(parameters)\(modifiers)^")
          }
          if fst <= snd && snd <= trd {
            return modifiers.contains(.colon) ? .break("") : .continue("")
          }
        } else {
          throw CLFormatError.malformedDirective("~\(parameters)\(modifiers)^")
        }
        return .append("")
      case .conversion(let control):
        let str = try control.format(with: arguments, in: context).string
        if !modifiers.contains(.colon) && !modifiers.contains(.at) {
          return .append(str.lowercased())
        } else if modifiers.contains(.colon) && !modifiers.contains(.at) {
          return .append(str.capitalized)
        } else if !modifiers.contains(.colon) && modifiers.contains(.at) {
          return .append(str.prefix(1).capitalized + str.dropFirst())
        } else {
          return .append(str.uppercased())
        }
      case .conditional(let controls, let defaultCase):
        if modifiers.contains(.colon) && modifiers.contains(.at) {
          throw CLFormatError.malformedDirective("~:@[")
        } else if modifiers.contains(.colon) {
          guard controls.count == 2, !defaultCase, parameters.parameterCount == 0 else {
            throw CLFormatError.malformedDirective("~:[")
          }
          return .append(try controls[arguments.next() == nil ? 0 : 1]
                               .format(with: arguments, in: context).string)
        } else if modifiers.contains(.at) {
          guard controls.count == 1, parameters.parameterCount == 0 else {
            throw CLFormatError.malformedDirective("~@[")
          }
          if try arguments.current() != nil {
            return .append(try controls[0].format(with: arguments, in: context).string)
          } else {
            _ = try arguments.next()
            return .append("")
          }
        } else {
          let choice = try parameters.number(0) ?? arguments.nextAsInt()
          if choice >= 0 && choice < controls.count {
            return .append(try controls[choice].format(with: arguments, in: context).string)
          } else if defaultCase {
            return .append(try controls.last!.format(with: arguments, in: context).string)
          } else {
            return .append("")
          }
        }
      case .iteration(let control):
        var res = ""
        let itercap = try parameters.number(0) ?? Int.max
        if modifiers.contains(.colon) {
          let iterargs = modifiers.contains(.at) ? arguments
                                                 : try arguments.nextAsArguments(maxArgs: itercap)
          while iterargs.left > 0 {
            let arg = try iterargs.next()
            var itercap = try parameters.number(1) ?? Int.max
            if let seq = arg as? any Sequence {
              var newargs = [Any?]()
              var iterator = seq.makeIterator() as (any IteratorProtocol)
              while itercap > 0, let next = iterator.next() {
                newargs.append(next)
                itercap -= 1
              }
              let formatted = try control.format(with: Arguments(locale: arguments.locale,
                                                                 tabsize: arguments.tabsize,
                                                                 args: newargs,
                                                                 numArgumentsLeft: iterargs.left),
                                                 in: .frame(res, context))
              res += formatted.string
              if case .break = formatted {
                break
              }
            } else if itercap > 0 {
              var newargs = [Any?]()
              newargs.append(arg)
              let formatted = try control.format(with: Arguments(locale: arguments.locale,
                                                                 tabsize: arguments.tabsize,
                                                                 args: newargs,
                                                                 numArgumentsLeft: iterargs.left),
                                                 in: .frame(res, context))
              res += formatted.string
              if case .break = formatted {
                break
              }
            }
          }
        } else {
          let iterargs = modifiers.contains(.at) ? arguments
                                                 : try arguments.nextAsArguments(maxArgs: itercap)
          let firstArg = iterargs.setFirstArg()
          while iterargs.left > 0 {
            res += try control.format(with: iterargs, in: .frame(res, context)).string
          }
          _ = iterargs.setFirstArg(to: firstArg)
        }
        return .append(res)
      case .justification(let sections, let spare, let linewidth):
        let mincol = try parameters.number(0) ?? 0
        let colinc = try parameters.number(1) ?? 1
        let minpad = try parameters.number(2) ?? 0
        let padchar = try parameters.character(3) ?? " "
        let maxcol = try parameters.number(4)
        let ellipsis = try parameters.character(5) ?? "…"
        let linewidth = linewidth ?? arguments.linewidth
        var strs = [String]()
        var len = modifiers.contains(.colon) ? minpad : 0
        loop: for section in sections {
          switch try section.format(with: arguments, in: context) {
            case .append(let str):
              strs.append(str)
              len += str.count + minpad
            case .continue(_):
              break loop
            case .break(_):
              throw CLFormatError.malformedDirective("~:^")
          }
        }
        guard strs.count > 0 else {
          return .append("")
        }
        if !modifiers.contains(.at) {
          len -= minpad
        }
        let width = len > mincol ? mincol + ((len - mincol + colinc - 1)/colinc) * colinc : mincol
        let ignore = spare == nil ? 0 : 1
        let gaps = strs.count - ignore - 1
                 + (modifiers.contains(.at) ? 1 : 0)
                 + (modifiers.contains(.colon) ? 1 : 0)
        var justified = ""
        if strs.count == 1 && ignore == 0, let maxcol = maxcol {
          justified = self.pad(string: strs[0],
                               left: modifiers.contains(.colon),
                               right: modifiers.contains(.at),
                               padchar: padchar,
                               ellipsis: ellipsis,
                               mincol: width,
                               colinc: 1,
                               minpad: 0,
                               maxcol: maxcol)
        } else if gaps == 0 {
          justified = String(repeating: padchar, count: width - len) + strs[ignore]
        } else {
          let minpad = (width - len) / gaps
          var nummaxpad = (width - len) % gaps
          var leftpad = modifiers.contains(.colon)
          for str in strs[ignore...] {
            if leftpad {
              justified += String(repeating: padchar, count: minpad + (nummaxpad > 0 ? 1 : 0))
              nummaxpad -= 1
            }
            justified += str
            leftpad = true
          }
          if modifiers.contains(.at) {
            justified += String(repeating: padchar, count: minpad)
          }
        }
        let col = context.current.currentColumn(tabsize: arguments.tabsize)
        if col + justified.count + (spare == nil ? 0 : spare!) <= linewidth {
          return .append(justified)
        } else {
          return .append(strs[0] + justified)
        }
      case .indirection:
        let control = try CLControl(string: try arguments.nextAsString(),
                                  config: context.parserConfig)
        if modifiers.contains(.at) {
          return .append(try control.format(with: arguments, in: context).string)
        } else {
          let args = try arguments.nextAsArguments()
          return .append(try control.format(with: args, in: context).string)
        }
      default:
        throw CLFormatError.unsupportedDirective("~\(self.identifier)")
    }
  }
  
  func pad(string: String,
           left: Bool,
           right: Bool,
           padchar: Character,
           ellipsis: Character,
           mincol: Int,
           colinc: Int,
           minpad: Int,
           maxcol: Int?) -> String {
    var str = string
    let count = string.count
    if let maxcol = maxcol, count > maxcol {
      str.removeLast(count - maxcol)
      if str.count > 1 {
        str.removeLast()
        str.append(ellipsis)
      }
    } else if count < mincol || minpad > 0 {
      var padcount = max(((mincol - str.count - minpad + colinc - 1) / colinc)
                         * colinc + minpad, minpad)
      if let maxcol = maxcol, padcount + count > maxcol {
        padcount = maxcol - count
      }
      if left && right {
        str = String(repeating: padchar, count: padcount - (padcount / 2)) + str +
              String(repeating: padchar, count: padcount / 2)
      } else {
        let padding = String(repeating: padchar, count: padcount)
        if right {
          str = str + padding
        } else {
          str = padding + str
        }
      }
    }
    return str
  }
  
  public var description: String {
    switch self {
      case .conversion(let control):
        return "(" + control.description + ")"
      case .conditional(let controls, let defaultCase):
        var res = "["
        var sep = ""
        for control in controls {
          res += "\(sep)\(control)"
          sep = "| "
        }
        return res + (defaultCase ? ":]" : "]")
      case .iteration(let control):
        return "{" + control.description + "}"
      default:
        return String(self.identifier)
    }
  }
}

public enum CLFormatError: Error, CustomStringConvertible {
  case malformedDirective(String)
  case unsupportedDirective(String)
  case argumentOutOfRange(Int, Int)
  case missingArgument
  case expectedNumberArgument(Int, Any)
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
}

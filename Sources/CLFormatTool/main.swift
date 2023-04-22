//
//  main.swift
//  CLFormat
//
//  Created by Matthias Zenger on 05/03/2023.
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
import CLFormat

enum ParseError: Error, CustomStringConvertible {
  case illegalArgumentLiteral
  case cannotParseNumber
  case cannotParseString
  case cannotParseCharacter
  case cannotParseSequence
  
  var description: String {
    switch self {
      case .illegalArgumentLiteral:
        return "illegal argument literal"
      case .cannotParseNumber:
        return "cannot parse number"
      case .cannotParseString:
        return "cannot parse string"
      case .cannotParseCharacter:
        return "cannot parse character"
      case .cannotParseSequence:
        return "cannot parse sequence"
    }
  }
}

func split(argument: String) -> [String] {
  var components: [String] = []
  var current = ""
  var inChar = false
  var inStr = false
  var enclSeq = 0
  for ch in argument {
    switch ch {
      case "'":
        if !inStr {
          inChar.toggle()
        }
      case "\"":
        if !inChar {
          inStr.toggle()
        }
      case "[":
        if !inStr && !inChar {
          enclSeq += 1
        }
      case "]":
        if !inStr && !inChar && enclSeq > 0 {
          enclSeq -= 1
        }
      case ",":
        if !inStr && !inChar && enclSeq == 0 {
          components.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
          current = ""
          continue
        }
      default:
        break
    }
    current.append(ch)
  }
  current = current.trimmingCharacters(in: .whitespacesAndNewlines)
  if !current.isEmpty {
    components.append(current)
  }
  return components
}

func parse(argument: String) throws -> Any? {
  guard !argument.isEmpty && argument != "nil" else {
    return nil
  }
  switch argument.first! {
    case "\"":
      if argument.count >= 2 && argument.last! == "\"" {
        let start = argument.index(after: argument.startIndex)
        let end = argument.index(before: argument.endIndex)
        return String(argument[start..<end])
      } else {
        throw ParseError.cannotParseString
      }
    case "'":
      if argument.count == 3 && argument.last! == "'" {
        return argument[argument.index(after: argument.startIndex)]
      } else {
        throw ParseError.cannotParseCharacter
      }
    case "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
      if let x = Int(argument) {
        return x
      } else if let x = Int64(argument) {
        return x
      } else if let x = Double(argument) {
        return x
      } else {
        throw ParseError.cannotParseNumber
      }
    case ".":
      if let x = Double(argument) {
        return x
      } else {
        throw ParseError.cannotParseNumber
      }
    case "[":
      if argument.count >= 2 && argument.last! == "]" {
        let start = argument.index(after: argument.startIndex)
        let end = argument.index(before: argument.endIndex)
        return try split(argument: String(argument[start..<end])).map(parse)
      } else {
        throw ParseError.cannotParseSequence
      }
    default:
      throw ParseError.illegalArgumentLiteral
  }
}

while true {
  print("  CONTROL│ ", terminator: "")
  guard let control = readLine()?.trimmingCharacters(in: .whitespaces),
        !control.isEmpty else {
    break
  }
  print("ARGUMENTS│ ", terminator: "")
  guard let argline = readLine()?.trimmingCharacters(in: .whitespaces) else {
    break
  }
  let arguments: String
  let locale: Locale?
  if argline.starts(with: "*") {
    print("   LOCALE│ ", terminator: "")
    guard let identifier = readLine()?.trimmingCharacters(in: .whitespaces) else {
      break
    }
    arguments = argline[argline.index(after: argline.startIndex)...]
                  .trimmingCharacters(in: .whitespaces)
    locale = Locale(identifier: identifier)
  } else {
    arguments = argline
    locale = nil
  }
  print("─────────┤")
  do {
    let args: [Any?] = try split(argument: arguments).map(parse)
    let formatted = try clformat(control, locale: locale, arguments: args)
      .replacingOccurrences(of: "\n", with: "\n         │ ")
    print("   RESULT│", formatted)
  } catch let e as ParseError {
    print("PARSERERR│", e.description)
  } catch let e as CLFormatError {
    print("FORMATERR│", e.description)
  } catch let e as CLControlError {
    print("CONTRLERR│", e.description)
  } catch let e {
    print("    ERROR│", e.localizedDescription)
  }
  print("═════════╪═══════════════════════════")
}

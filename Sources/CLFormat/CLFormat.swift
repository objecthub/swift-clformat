//
//  Format.swift
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

protocol CLFormatConvertible {
  var clformatDescription: String { get }
}

protocol DebugCLFormatConvertible {
  var clformatDebugDescription: String { get }
}

extension Array: CLFormatConvertible where Element: CLFormatConvertible {
  var clformatDescription: String {
    var res = "["
    var sep = ""
    for element in self {
      res += sep + element.clformatDescription
      sep = ", "
    }
    return res + "]"
  }
}

extension Array: DebugCLFormatConvertible where Element: DebugCLFormatConvertible {
  var clformatDebugDescription: String {
    var res = "["
    var sep = ""
    for element in self {
      res += sep + element.clformatDebugDescription
      sep = ", "
    }
    return res + "]"
  }
}

extension Optional: CLFormatConvertible, DebugCLFormatConvertible {
  var clformatDescription: String {
    switch self {
      case .none:
        return "nil"
      case .some(let value):
        if let x = value as? CLFormatConvertible {
          return x.clformatDescription
        } else if let x = value as? CustomDebugStringConvertible {
          return x.debugDescription
        } else {
          return "\(value)"
        }
    }
  }
  
  var clformatDebugDescription: String {
    switch self {
      case .none:
        return "nil"
      case .some(let value):
        if let x = value as? DebugCLFormatConvertible {
          return x.clformatDebugDescription
        } else if let x = value as? CustomDebugStringConvertible {
          return x.debugDescription
        } else {
          return "\(value)"
        }
    }
  }
}

extension String {
  
  public init(control: String,
              config: CLFormatConfig? = nil,
              locale: Locale? = nil,
              tabsize: Int = 4,
              linewidth: Int = 80,
              args: Any?...) throws {
    let control = try CLControl(string: control, config: config)
    try self.init(control.format(locale: locale,
                                 tabsize: tabsize,
                                 linewidth: linewidth,
                                 args: args))
  }
  
  public init(control: String,
              config: CLFormatConfig? = nil,
              locale: Locale? = nil,
              tabsize: Int = 4,
              linewidth: Int = 80,
              arguments: [Any?]) throws {
    let control = try CLControl(string: control, config: config)
    try self.init(control.format(locale: locale,
                                 tabsize: tabsize,
                                 linewidth: linewidth,
                                 args: arguments))
  }
  
  internal func currentColumn(tabsize: Int = 8) -> Int {
    let index = self.lastIndex(of: "\n")
    var i = index == nil ? self.startIndex : self.index(after: index!)
    var col = 0
    while i < self.endIndex {
      if self[i] == "\t" {
        col += tabsize - (col % tabsize)
      } else {
        col += 1
      }
      i = self.index(after: i)
    }
    return col
  }
}

public func clformat(_ control: String,
                     config: CLFormatConfig? = CLFormatConfig.default,
                     locale: Locale? = nil,
                     tabsize: Int = 4,
                     linewidth: Int = 80,
                     args: Any?...) throws -> String {
  let control = try CLControl(string: control, config: config)
  return try control.format(locale: locale,
                            tabsize: tabsize,
                            linewidth: linewidth,
                            args: args)
}

public func clformat(_ control: String,
                     config: CLFormatConfig? = CLFormatConfig.default,
                     locale: Locale? = nil,
                     tabsize: Int = 4,
                     linewidth: Int = 80,
                     arguments: [Any?]) throws -> String {
  let control = try CLControl(string: control, config: config)
  return try control.format(locale: locale,
                            tabsize: tabsize,
                            linewidth: linewidth,
                            args: arguments)
}

public func clprintf(_ control: String,
                     config: CLFormatConfig? = CLFormatConfig.default,
                     locale: Locale? = nil,
                     tabsize: Int = 4,
                     linewidth: Int = 80,
                     args: Any?...,
                     terminator: String = "\n") throws {
  print(try clformat(control,
                     config: config,
                     locale: locale,
                     tabsize: tabsize,
                     linewidth: linewidth,
                     arguments: args),
        terminator: terminator)
}

public func clprintf(_ control: String,
                     config: CLFormatConfig? = CLFormatConfig.default,
                     locale: Locale? = nil,
                     tabsize: Int = 4,
                     linewidth: Int = 80,
                     arguments: [Any?],
                     terminator: String = "\n") throws {
  print(try clformat(control,
                     config: config,
                     locale: locale,
                     tabsize: tabsize,
                     linewidth: linewidth,
                     arguments: arguments),
        terminator: terminator)
}

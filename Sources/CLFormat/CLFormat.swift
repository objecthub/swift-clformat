//
//  Format.swift
//  CommonLispFormat
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

extension String {
  
  init(control: String,
       config: ControlParserConfig? = nil,
       locale: Locale? = nil,
       tabsize: Int = 8,
       _ args: Any?...) throws {
    let control = try Control(string: control, config: config)
    try self.init(control.format(with: Arguments(locale: locale, tabsize: tabsize, args: args),
                                 in: .root(control.config)).string)
  }
  
  init(control: String,
       config: ControlParserConfig? = nil,
       locale: Locale? = nil,
       tabsize: Int = 8,
       arguments: [Any?]) throws {
    let control = try Control(string: control, config: config)
    try self.init(control.format(with: Arguments(locale: locale, tabsize: tabsize, args: arguments),
                                 in: .root(control.config)).string)
  }
  
  func currentColumn(tabsize: Int = 8) -> Int {
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

func clformat(_ control: String,
              config: ControlParserConfig? = nil,
              locale: Locale? = nil,
              tabsize: Int = 8,
              args: Any?...) throws -> String {
  let control = try Control(string: control, config: config)
  return try control.format(with: Arguments(locale: locale, tabsize: tabsize, args: args),
                            in: .root(control.config)).string
}

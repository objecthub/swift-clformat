//
//  Control.swift
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

public struct Control: CustomStringConvertible {
  
  public enum Component: CustomStringConvertible {
    case text(Substring)
    case directive(Directive)
    
    public var description: String {
      switch self {
        case .text(let str):
          return "\"\(str)\""
        case .directive(let dir):
          return dir.description
      }
    }
  }
  
  public let config: ControlParserConfig
  private let components: [Component]
  
  public init(components: [Component], config: ControlParserConfig? = nil) {
    self.config = config ?? ControlParserConfig.standard
    self.components = components
  }
  
  public init(string: String, config: ControlParserConfig? = nil) throws {
    self = try ControlParser(control: string,
                             config: config ?? ControlParserConfig.standard).parse()
  }
  
  public func format(locale: Locale? = nil, tabsize: Int = 8, args: Any?...) throws -> String {
    return try self.format(with: Arguments(locale: locale, tabsize: tabsize, args: args),
                           in: .root(self.config)).string
  }
  
  public func format(with args: Arguments, in context: Context) throws -> Instruction {
    var res = ""
    for component in self.components {
      switch component {
        case .text(let str):
          res += str
        case .directive(let dir):
          switch try dir.specifier.apply(context: .frame(res, context),
                                         parameters: dir.parameters.process(arguments: args),
                                         modifiers: dir.modifiers,
                                         arguments: args) {
            case .append(let str):
              res += str
            case .continue(let str):
              return .continue(res + str)
            case .break(let str):
              return .break(res + str)
          }
      }
    }
    return .append(res)
  }
  
  public var description: String {
    var res = ""
    var sep = ""
    for component in self.components {
      res += "\(sep)\(component)"
      sep = ", "
    }
    return res
  }
}

public enum Context {
  case root(ControlParserConfig)
  indirect case frame(String, Context)
  
  public var current: String {
    switch self {
      case .root(_):
        return ""
      case .frame(let str, let context):
        return context.current + str
    }
  }
  
  public var parserConfig: ControlParserConfig {
    switch self {
      case .root(let config):
        return config
      case .frame(_, let context):
        return context.parserConfig
    }
  }
}

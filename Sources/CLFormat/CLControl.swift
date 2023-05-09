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

///
/// Struct `Control` represents a parsed control string. The driver of the
/// format function is provided by this struct. The format function can be
/// called arbitrary many times for a given struct (it is reentrant as well).
/// 
/// A `Control` value consists of a control parser configuration as well as
/// a sequence of "components". A component is either a text fragment or a
/// formatting directive.
/// 
public struct CLControl: CustomStringConvertible {
  
  /// Implementation of control components as an enumeration.
  public enum Component: CustomStringConvertible {
    case text(Substring)
    case directive(Directive)
    
    /// Returns a string representation of this component.
    public var description: String {
      switch self {
        case .text(let str):
          return "\"\(str)\""
        case .directive(let dir):
          return dir.description
      }
    }
  }
  
  /// The control parser configuration. This value needs to be preserved
  /// because there is the need to potentially parse arguments as control
  /// strings, e.g. via the ~?/indirection directive.
  public let config: CLControlParserConfig
  
  /// The parsed control components.
  public let components: [Component]
  
  /// Constructor for manually creating control values.
  public init(components: [Component], config: CLControlParserConfig? = nil) {
    self.config = config ?? CLControlParserConfig.standard
    self.components = components
  }
  
  /// Constructor for parsing a control string into a control value.
  public init(string: String, config: CLControlParserConfig? = nil) throws {
    self = try CLControlParser(control: string,
                             config: config ?? CLControlParserConfig.standard).parse()
  }
  
  /// Returns true if the control string was empty.
  public var isEmpty: Bool {
    return self.components.isEmpty
  }
  
  /// Main format function. Creates an `Argument` object from the given parameters
  /// and invokes the driver of the formatting logic.
  public func format(locale: Locale? = nil,
                     tabsize: Int = 4,
                     linewidth: Int = 80,
                     args: Any?...) throws -> String {
    return try self.format(with: self.config.makeArguments(locale: locale,
                                                           tabsize: tabsize,
                                                           linewidth: linewidth,
                                                           args: args),
                           in: .root(self.config)).string
  }
  
  /// Main format function. Creates an `Argument` object from the given parameters
  /// and invokes the driver of the formatting logic.
  public func format(locale: Locale? = nil,
                     tabsize: Int = 4,
                     linewidth: Int = 80,
                     arguments: [Any?]) throws -> String {
    return try self.format(with: self.config.makeArguments(locale: locale,
                                                           tabsize: tabsize,
                                                           linewidth: linewidth,
                                                           args: arguments),
                           in: .root(self.config)).string
  }
  
  /// Driver of the formatting logic. Can be called directly for low-level applications.
  /// Typically, this is not called directly.
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
  
  /// Returns a description of this control value.
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

///
/// A `Context` value represents a formatting context (i.e. a linked list of
/// context values. The root refers to the control parser configuration (to make
/// it accessible from the formatting logic).
/// 
public enum Context {
  case root(CLControlParserConfig)
  indirect case frame(String, Context)
  
  public var current: String {
    switch self {
      case .root(_):
        return ""
      case .frame(let str, let context):
        return context.current + str
    }
  }
  
  public var parserConfig: CLControlParserConfig {
    switch self {
      case .root(let config):
        return config
      case .frame(_, let context):
        return context.parserConfig
    }
  }
}

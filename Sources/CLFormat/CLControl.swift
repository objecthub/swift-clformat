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
/// A `Control` value consists of a format configuration as well as
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
  
  /// The format configuration. This value needs to be preserved
  /// because there is the need to potentially parse arguments as control
  /// strings, e.g. via the ~?/indirection directive.
  public let config: CLFormatConfig
  
  /// The parsed control components.
  public let components: [Component]
  
  /// Constructor for manually creating control values.
  public init(components: [Component], config: CLFormatConfig? = nil) {
    self.config = config ?? CLFormatConfig.standard
    self.components = components
  }
  
  /// Constructor for parsing a control string into a control value.
  public init(string: String, config: CLFormatConfig? = nil) throws {
    self = try CLControlParser(control: string,
                             config: config ?? CLFormatConfig.standard).parse()
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
                           in: Context(config: self.config)).string
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
                           in: Context(config: self.config)).string
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
          switch try dir.specifier.apply(context: context.drop(res),
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
/// A `Context` value represents a formatting context, i.e. a linked list of
/// `History` values and a format configuration.
///
public struct Context {
  
  public enum History {
    case root
    indirect case frame(String, History)
    
    public var string: String {
      switch self {
        case .root:
          return ""
        case .frame(let str, let history):
          return history.string + str
      }
    }
  }
  
  let config: CLFormatConfig
  let output: History
  
  init(config: CLFormatConfig, output: History = .root) {
    self.config = config
    self.output = output
  }
  
  public func reconfig(_ config: CLFormatConfig) -> Context {
    return Context(config: config, output: self.output)
  }
  
  public func drop(_ str: String) -> Context {
    return Context(config: self.config, output: .frame(str, self.output))
  }
  
  public var current: String {
    return self.output.string
  }
}

//
//  Arguments.swift
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

///
/// Class `Arguments` is used to encapsulate arguments and environment variables.
/// An instance of `Arguments` is passed to the format function when interpreting
/// the control string. `Argument` objects cannot be reused. They can only be used
/// once to format a string.
/// 
open class Arguments: CustomStringConvertible {
  
  /// The locale to be used (for locale-specific directives; typically enabled
  /// via the `+` modifier.
  public let locale: Locale?
  
  /// The size of tabs.
  public let tabsize: Int
  
  /// The maximum length of a line.
  public let linewidth: Int
  
  /// The arguments used to format a string.
  private let args: [Any?]
  
  /// Index pointing at the next argument to consume.
  private var index: Int
  
  /// If this instance isn't referring to all arguments (at formatting time,
  /// nested arguments might be created, e.g. to implement the ~?/indirection
  /// directive.
  internal let numArgumentsLeft: Int?
  
  /// The first argument to consume.
  private var firstArg: Int
  
  /// Constructor.
  public required init(locale: Locale? = nil,
                       tabsize: Int = 8,
                       linewidth: Int = 80,
                       args: [Any?],
                       numArgumentsLeft: Int? = nil) {
    self.locale = locale
    self.tabsize = tabsize
    self.linewidth = linewidth
    self.args = args
    self.index = 0
    self.numArgumentsLeft = numArgumentsLeft
    self.firstArg = 0
  }
  
  /// Returns the total number of available arguments.
  public var count: Int {
    return self.args.count
  }
  
  /// Returns the number of arguments that are still available for consumption.
  public var left: Int {
    return self.args.count - self.index
  }
  
  /// Returns the current first argument and sets a new first argument.
  public func setFirstArg(to f: Int? = nil) -> Int {
    let res = self.firstArg
    self.firstArg = f ?? self.index
    return res
  }
  
  /// Advances the next available argument by `n`. The resulting index must be
  /// between `firstArg` and the total number of available arguments.
  public func advance(by n: Int = 1) throws {
    if self.index + n >= self.firstArg && self.index + n <= self.args.count {
      self.index += n
    } else {
      throw CLFormatError.argumentOutOfRange(self.index + n, self.args.count)
    }
  }
  
  /// Sets the next argument to consume to `i`, relative to `firstArg`.
  public func jump(to i: Int) throws {
    if i >= 0 && i <= self.args.count - self.firstArg {
      self.index = self.firstArg + i
    } else {
      throw CLFormatError.argumentOutOfRange(i, self.args.count)
    }
  }
  
  /// Returns the next argument to consume; this is, in fact, a lookahead as
  /// the next argument is not being consumed by `current`.
  open func current() throws -> Any? {
    if self.index < self.args.count {
      return self.args[self.index]
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  /// Returns and consumes the next argument.
  open func next() throws -> Any? {
    if self.index < self.args.count {
      let arg = self.args[self.index]
      self.index += 1
      return arg
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  /// Returns and consumes the next argument as a number. The function throws an
  /// exception if the next argument is not a number.
  public func nextAsNumber() throws -> Number {
    if let arg = try self.next() {
      if let num = self.coerceToNumber(arg) {
        return num
      } else {
        throw CLFormatError.expectedNumberArgument(self.index - 1, arg)
      }
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  /// Returns and consumes the next argument as an `Int`. The function throws an
  /// exception if the next argument cannot be exactly represented as an `Int`.
  public func nextAsInt() throws -> Int {
    if let arg = try self.next() {
      if let num = self.coerceToInt(arg) {
        return num
      } else {
        throw CLFormatError.expectedNumberArgument(self.index - 1, arg)
      }
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  /// Returns and consumes the next argument as a character. The function throws an
  /// exception if the next argument is not a character.
  public func nextAsCharacter() throws -> Character {
    if let arg = try self.next() {
      if let ch = self.coerceToCharacter(arg) {
        return ch
      } else if let str = arg as? String, str.count == 1 {
        return str.first!
      } else  {
        throw CLFormatError.expectedNumberArgument(self.index - 1, arg)
      }
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  /// Returns and consumes the next argument as a string. The function throws an
  /// exception if the next argument is not a string.
  public func nextAsString() throws -> String {
    if let arg = try self.next() {
      if let str = self.coerceToString(arg) {
        return str
      } else  {
        throw CLFormatError.expectedNumberArgument(self.index - 1, arg)
      }
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  /// Returns and consumes the next argument as an `Arguments` object. The function throws
  /// an exception if the next argument is not a sequence (which is being converted into an
  /// `Arguments` object).
  public func nextAsArguments(maxArgs: Int = Int.max) throws -> Self {
    if let arg = try self.next() {
      if let arr = self.coerceToArray(arg, capAt: maxArgs) {
        return Self(locale: self.locale, tabsize: self.tabsize, args: arr)
      } else {
        throw CLFormatError.expectedSequenceArgument(self.index - 1, arg)
      }
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  /// Returns and consumes the next argument as a parameter. The function throws an
  /// exception if the next argument cannot be represented as a parameter.
  public func nextAsParameter() throws -> Parameter {
    if let arg = try self.next() {
      if let param = self.coerceToParameter(arg) {
        return param
      } else {
        throw CLFormatError.cannotUseArgumentAsParameter(self.index - 1, arg)
      }
    } else {
      return .none
    }
  }
  
  /// Returns a string representation of the arguments.
  public var description: String {
    var res = "<Arguments:"
    var sep = " "
    if let locale = self.locale {
      res += "\(sep)locale = \(locale)"
      sep = ", "
    }
    res += "\(sep)tabsize = \(self.tabsize)"
    sep = ", "
    res += "\(sep)linewidth = \(self.linewidth)"
    res += "\(sep)args = ["
    sep = ""
    for arg in self.args[self.index..<self.args.count] {
      if let arg = arg {
        res += "\(sep)\(arg)"
      } else {
        res += "\(sep)nil"
      }
      sep = ", "
    }
    return res + "]>"
  }
  
  /// Coerce object to a Number value, if possible.
  open func coerceToNumber(_ obj: Any) -> Number? {
    return Number(obj)
  }
  
  /// Coerce object to an integer, if possible.
  open func coerceToInt(_ obj: Any) -> Int? {
    if let num = obj as? Int {
      return num
    } else if let n = obj as? Int64, let num = Int(exactly: n) {
      return num
    } else if let n = obj as? UInt, let num = Int(exactly: n) {
      return num
    } else if let n = obj as? UInt64, let num = Int(exactly: n) {
      return num
    } else {
      return nil
    }
  }
  
  /// Coerce object to a character, if possible.
  open func coerceToCharacter(_ obj: Any) -> Character? {
    if let ch = obj as? Character {
      return ch
    } else if let str = obj as? String, str.count == 1 {
      return str.first!
    } else  {
      return nil
    }
  }
  
  /// Coerce object to a string, if possible.
  open func coerceToString(_ obj: Any) -> String? {
    if let str = obj as? String {
      return str
    } else if let str = obj as? NSString {
      return str as String
    } else if let str = obj as? NSMutableString {
      return str as String
    } else  {
      return nil
    }
  }
  
  /// Coerce object to an array, if possible.
  open func coerceToArray(_ obj: Any, capAt: Int) -> [Any?]? {
    if let seq = obj as? any Sequence {
      var itercap = capAt
      var newargs = [Any?]()
      var iterator = seq.makeIterator() as (any IteratorProtocol)
      while itercap > 0, let next = iterator.next() {
        newargs.append(unwrapAny(next))
        itercap -= 1
      }
      return newargs
    } else {
      return nil
    }
  }
  
  /// Coerce object to a parameter, if possible.
  open func coerceToParameter(_ obj: Any) -> Parameter? {
    if let num = self.coerceToInt(obj) {
      return .number(num)
    } else if let char = self.coerceToCharacter(obj) {
      return .character(char)
    } else if let str = self.coerceToString(obj), str.count < 2 {
      return str.count == 0 ? Parameter.none : Parameter.character(str.first!)
    } else {
      return nil
    }
  }
}

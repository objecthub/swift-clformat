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

public class Arguments: CustomStringConvertible {
  public let locale: Locale?
  public let tabsize: Int
  private let args: [Any?]
  private var index: Int
  internal let numArgumentsLeft: Int?
  private var firstArg: Int
  
  public init(locale: Locale? = nil, tabsize: Int = 8, args: [Any?], numArgumentsLeft: Int? = nil) {
    self.locale = locale
    self.tabsize = tabsize
    self.args = args
    self.index = 0
    self.numArgumentsLeft = numArgumentsLeft
    self.firstArg = 0
  }
  
  public var count: Int {
    return self.args.count
  }
  
  public var left: Int {
    return self.args.count - self.index
  }
  
  public func setFirstArg(to f: Int? = nil) -> Int {
    let res = self.firstArg
    self.firstArg = f ?? self.index
    return res
  }
  
  public func advance(by n: Int = 1) throws {
    if self.index + n >= self.firstArg && self.index + n <= self.args.count {
      self.index += n
    } else {
      throw CLFormatError.argumentOutOfRange(self.index + n, self.args.count)
    }
  }
  
  public func jump(to i: Int) throws {
    if i >= 0 && i <= self.args.count - self.firstArg {
      self.index = self.firstArg + i
    } else {
      throw CLFormatError.argumentOutOfRange(i, self.args.count)
    }
  }
  
  public func current() throws -> Any? {
    if self.index < self.args.count {
      return self.args[self.index]
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  public func next() throws -> Any? {
    if self.index < self.args.count {
      let arg = self.args[self.index]
      self.index += 1
      return arg
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  public func nextAsNumber() throws -> Number {
    if let arg = try self.next() {
      if let num = Number(arg) {
        return num
      } else {
        throw CLFormatError.expectedNumberArgument(self.index - 1, arg)
      }
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  public func nextAsInt() throws -> Int {
    if let arg = try self.next() {
      if let num = arg as? Int {
        return num
      } else if let n = arg as? Int64, let num = Int(exactly: n) {
        return num
      } else if let n = arg as? UInt, let num = Int(exactly: n) {
        return num
      } else if let n = arg as? UInt64, let num = Int(exactly: n) {
        return num
      } else {
        throw CLFormatError.expectedNumberArgument(self.index - 1, arg)
      }
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  public func nextAsCharacter() throws -> Character {
    if let arg = try self.next() {
      if let ch = arg as? Character {
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
  
  public func nextAsString() throws -> String {
    if let arg = try self.next() {
      if let str = arg as? String {
        return str
      } else if let str = arg as? NSString {
        return str as String
      } else if let str = arg as? NSMutableString {
        return str as String
      } else  {
        throw CLFormatError.expectedNumberArgument(self.index - 1, arg)
      }
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  public func nextAsArguments(maxArgs: Int = Int.max) throws -> Arguments {
    if let arg = try self.next() {
      if let seq = arg as? any Sequence {
        var newargs = [Any?]()
        var itercap = maxArgs
        var iterator = seq.makeIterator() as (any IteratorProtocol)
        while itercap > 0, let next = iterator.next() {
          newargs.append(next)
          itercap -= 1
        }
        return Arguments(locale: self.locale,
                         tabsize: self.tabsize,
                         args: newargs)
      } else {
        throw CLFormatError.expectedNumberArgument(self.index - 1, arg)
      }
    } else {
      throw CLFormatError.missingArgument
    }
  }
  
  public func nextAsParameter() throws -> Parameter {
    if let arg = try self.next() {
      if let num = arg as? Int {
        return .number(num)
      } else if let n = arg as? Int64, let num = Int(exactly: n) {
        return .number(num)
      } else if let n = arg as? UInt, let num = Int(exactly: n) {
        return .number(num)
      } else if let n = arg as? UInt64, let num = Int(exactly: n) {
        return .number(num)
      } else if let char = arg as? Character {
        return .character(char)
      } else if let str = arg as? String, str.count < 2 {
        return str.count == 0 ? .none : .character(str.first!)
      } else {
        throw CLFormatError.cannotUseArgumentAsParameter(self.index - 1, arg)
      }
    } else {
      return .none
    }
  }
  
  public var description: String {
    var res = "["
    var sep = ""
    for arg in self.args[self.index..<self.args.count] {
      if let arg = arg {
        res += "\(sep)\(arg)"
      } else {
        res += "\(sep)nil"
      }
      sep = ", "
    }
    return res + "]"
  }
}

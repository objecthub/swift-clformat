//
//  CLFormatRobustnessTests.swift
//  CLFormatTests
//
//  Created by Matthias Zenger on 10/10/2026.
//  Copyright © 2026 Matthias Zenger. All rights reserved.
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

import XCTest
@testable import CLFormat

///
/// Regression tests for control strings and arguments that used to crash the process
/// (arithmetic overflow, failed conversions, division by zero, negative repeat counts) or
/// to hang it. All of them are expected to either produce a result or to throw an error.
///
final class CLFormatRobustnessTests: XCTestCase {

  // MARK: - Numeric parameters

  func testParameterLimit() throws {
    let limit = Parameters.maxNumber
    // The largest permitted number works; one more is rejected by the control parser.
    XCTAssertEqual(try clformat("~\(limit)A", args: "x").count, limit)
    XCTAssertThrowsError(try clformat("~\(limit + 1)A", args: "x")) { error in
      guard case CLControlError.malformedNumericParameter(let num) = error else {
        return XCTFail("unexpected error: \(error)")
      }
      XCTAssertEqual(num, "\(limit + 1)")
    }
    XCTAssertThrowsError(try clformat("~-\(limit + 1)F", args: 1.5))
    XCTAssertThrowsError(try clformat("~99999999999999999999A", args: "x"))
    XCTAssertThrowsError(try clformat("~9223372036854775807D", args: 1))
    XCTAssertThrowsError(try clformat("~,,,,,,,,9223372036854775807E", args: 1.5))
  }

  func testParameterLimitForArguments() throws {
    XCTAssertEqual(try clformat("|~vA|", args: 3, "x"), "|x  |")
    XCTAssertThrowsError(try clformat("|~vA|", args: Parameters.maxNumber + 1, "x")) { error in
      guard case CLFormatError.cannotUseArgumentAsParameter(let index, _) = error else {
        return XCTFail("unexpected error: \(error)")
      }
      XCTAssertEqual(index, 0)
    }
    XCTAssertThrowsError(try clformat("|~vA|", args: Int.max, "x"))
    XCTAssertThrowsError(try clformat("|~vA|", args: Int.min, "x"))
  }

  // MARK: - Currencies

  func testNumericCurrencyCodeOutOfRange() throws {
    XCTAssertNil(Currency(numericCode: 70000))
    XCTAssertNil(Currency(numericCode: -1))
    XCTAssertNil(Currency(numericCode: Int.max))
    XCTAssertNil(Currency(numericCode: Int.min))
    XCTAssertEqual(Currency(numericCode: 978)?.alphabeticCode, "EUR")
    // Unknown currencies simply do not produce a currency symbol
    XCTAssertEqual(try clformat("~,,,,70000$", args: 1.5), "1.50")
    XCTAssertEqual(try clformat("~,,,,-70000$", args: 1.5), "1.50")
    XCTAssertEqual(try clformat("~,,,,999$", args: 1.5), "1.50")
  }

  // MARK: - Radix

  func testIllegalRadix() throws {
    for radix in [0, 1, 37, 100, Parameters.maxNumber] {
      XCTAssertThrowsError(try clformat("~\(radix)R", args: 10)) { error in
        guard case CLFormatError.cannotRepresentNumber(_, let r) = error else {
          return XCTFail("unexpected error: \(error)")
        }
        XCTAssertEqual(r, radix)
      }
    }
    XCTAssertEqual(try clformat("~2R", args: 5), "101")
    XCTAssertEqual(try clformat("~36R", args: 123456), "2n9c")
    XCTAssertNil(NumberFormat.format(.int(10), radix: 1, mincol: 0, padchar: " ", groupsep: ",",
                                     groupsize: 3, usegroup: false, forcesign: false,
                                     uppercase: false, force: true))
    XCTAssertNil(NumberFormat.format(.int(10), radix: 37, mincol: 0, padchar: " ", groupsep: ",",
                                     groupsize: 3, usegroup: false, forcesign: false,
                                     uppercase: false, force: true))
  }

  func testZeroGroupSize() throws {
    // A group size of 0 used to cause an infinite loop; now grouping is skipped.
    XCTAssertEqual(try clformat("~,,' ,0:B", args: 255), "11111111")
    XCTAssertEqual(try clformat("~,,' ,0:O", args: 255), "377")
    XCTAssertEqual(try clformat("~,,' ,0:X", args: 255), "ff")
    XCTAssertEqual(try clformat("~16,,,' ,0:R", args: 255), "ff")
    XCTAssertEqual(try clformat("~,,' ,4:B", args: 255), "1111 1111")
  }

  // MARK: - Floating-point numbers

  func testNonFiniteNumbers() throws {
    let numbers: [Double] = [.infinity, -.infinity, .nan]
    for number in numbers {
      // Infinity and NaN are rendered like in the fixed-point style
      XCTAssertEqual(try clformat("~E", args: number), try clformat("~F", args: number))
      XCTAssertEqual(try clformat("~G", args: number), try clformat("~F", args: number))
      XCTAssertEqual(try clformat("~12E", args: number), try clformat("~12F", args: number))
      XCTAssertEqual(try clformat("~12G", args: number), try clformat("~12F", args: number))
      XCTAssertEqual(try clformat("~12,3,2,1E", args: number), try clformat("~12F", args: number))
      XCTAssertEqual(try clformat("~12F", args: number).count, 12)
      _ = try clformat("~,2F", args: number)
      _ = try clformat("~$", args: number)
      _ = try clformat("~D", args: number)
    }
    XCTAssertTrue(try clformat("~G", args: Double.infinity).contains("∞"))
    XCTAssertTrue(try clformat("~E", args: -Double.infinity).contains("∞"))
    XCTAssertTrue(try clformat("~G", args: Float.infinity).contains("∞"))
  }

  func testFixedFloatWithWidthAndNegativeNumbers() throws {
    // `~wF` without fraction digits used to crash for every negative number
    XCTAssertEqual(try clformat("~10F", args: -3.5), "      -3.5")
    XCTAssertEqual(try clformat("~10F", args: 3.5), "       3.5")
    XCTAssertEqual(try clformat("~10F", args: -0.5), "      -0.5")
    XCTAssertEqual(try clformat("~10F", args: 0.0), "       0.0")
    XCTAssertEqual(try clformat("~10,,,,'*F", args: -3.5), "******-3.5")
    XCTAssertEqual(try clformat("~5F", args: -123456.789), "-123456.789")
    XCTAssertEqual(try clformat("~10F", args: -12), "     -12.0")
    XCTAssertEqual(try clformat("~10,,,'*F", args: -12345678901.5), "**********")
  }

  func testExponentDigits() throws {
    // The exponent field is a minimum width; longer exponents used to crash the formatter
    XCTAssertEqual(try clformat("~,,0E", args: 3.14), "3.14E+0")
    XCTAssertEqual(try clformat("~,,1E", args: 3.14), "3.14E+0")
    XCTAssertEqual(try clformat("~,,1E", args: 3.14e10), "3.14E+10")
    XCTAssertEqual(try clformat("~,,1E", args: 3.14e-10), "3.14E-10")
    XCTAssertEqual(try clformat("~,,2E", args: 3.14e100), "3.14E+100")
    XCTAssertEqual(try clformat("~,,1@E", args: -3.14e-100), "-3.14E-100")
    XCTAssertEqual(try clformat("~,,0G", args: 3.14e100), "3.14E+100")
  }

  func testNegativeScaleFactorWithIntegers() throws {
    // The formatter used to scale numbers by 10^k via a multiplier; for integers this
    // overflowed (Int64) and printed the digits of Int.max instead of the argument.
    XCTAssertEqual(try clformat("~,,,-20E", args: 7), "0.000000000000000000007E+21")
    XCTAssertEqual(try clformat("~,,,-10E", args: 123456789012), "0.0000000000123456789012E+22")
    XCTAssertEqual(try clformat("~,,,-10:@E", args: -7), "-0.00000000007E+11")
    XCTAssertEqual(try clformat("~,5,,-3E", args: 1_000_000_000_000_000_000), "0.00010E+22")
    // Integers and equivalent doubles yield the same output
    for value in [7, -7, 255, 12345, 123456789012, 1_000_000_000_000_000_000, 99999] {
      for control in ["~,,,-1E", "~,,,-3E", "~,5,,-3E", "~,12,,-10E", "~,,2,-17E",
                      "~,,,-19E", "~,,,-20E", "~,,,-50E", "~15,,,-20E", "~,,,-20G"] {
        XCTAssertEqual(try clformat(control, args: value),
                       try clformat(control, args: Double(value)),
                       "\(control) with \(value)")
      }
    }
  }

  func testLargeNegativeScaleFactors() throws {
    // Shifting the exponent used to overflow Double (multiplier 10^k) and print infinity
    for shift in [300, 308, 309, 400, 1000] {
      XCTAssertEqual(try clformat("~,,,-\(shift)E", args: 7.0),
                     "0." + String(repeating: "0", count: shift) + "7E+\(shift + 1)")
      XCTAssertEqual(try clformat("~,,,-\(shift)E", args: 7),
                     "0." + String(repeating: "0", count: shift) + "7E+\(shift + 1)")
    }
    XCTAssertEqual(try clformat("~,500,,-400E", args: 7.5),
                   "0." + String(repeating: "0", count: 400) + "75" +
                   String(repeating: "0", count: 98) + "E+401")
    XCTAssertEqual(try clformat("~,,,-400E", args: 0.0),
                   "0." + String(repeating: "0", count: 400) + "0E+0")
  }

  func testDecimalNumbersKeepTheirPrecision() throws {
    // `NSDecimalNumber` arguments used to be converted to `Double`, losing digits
    let decimal = try XCTUnwrap(Decimal(string: "12345678901234567890.123456789"))
    let expected = "12345678901234567890.123456789"
    XCTAssertEqual(try clformat("~,9F", args: decimal), expected)
    XCTAssertEqual(try clformat("~,9F", args: NSDecimalNumber(decimal: decimal)), expected)
    XCTAssertEqual(try clformat("~,9F", args: NSDecimalNumber(string: "12345678901234567890.123456789")),
                   expected)
    XCTAssertEqual(try clformat("~,2F", args: NSDecimalNumber(string: "0.126")), "0.13")
  }
  
  func testDegenerateExponentParameters() throws {
    // Zero fraction digits combined with a non-positive scale factor used to crash
    // the formatter (negative repeat count). The exact output is not specified; the
    // directives merely need to produce a result.
    for control in ["~,0,,0E", "~,0,,1E", "~,0,,-1E", "~,0,,-100E", "~,1,,-100E",
                    "~0,0,5,-100G", "~0,0,5,-100@+G", "~,,,-100E", "~,,,100E"] {
      XCTAssertFalse(try clformat(control, args: 3.14).isEmpty, control)
      XCTAssertFalse(try clformat(control, args: -7).isEmpty, control)
    }
  }

  // MARK: - Padding and justification

  func testZeroColumnIncrement() throws {
    // A column increment of 0 used to cause a division by zero
    XCTAssertEqual(try clformat("|~5,0A|", args: "ab"), "|ab   |")
    XCTAssertEqual(try clformat("|~5,0@A|", args: "ab"), "|   ab|")
    XCTAssertEqual(try clformat("|~5,0S|", args: "ab"), "|\"ab\" |")
    XCTAssertEqual(try clformat("|~5,0W|", args: "ab"), "|ab   |")
    XCTAssertEqual(try clformat("|~1,0A|", args: "abc"), "|abc|")
    XCTAssertEqual(try clformat("|~0,0,0<x~>|"), "|x|")
    XCTAssertEqual(try clformat("|~10,0<x~>|"), "|         x|")
    XCTAssertEqual(try clformat("|~4,0:@<x~>|"), "|  x |")
  }

  func testMaximumColumnSmallerThanString() throws {
    // A maximum column of 0 combined with a one-character string used to cause a
    // negative padding count
    XCTAssertEqual(try clformat("|~5,1,0,,0A|", args: "a"), "|a|")
    XCTAssertEqual(try clformat("|~5,1,0,,0@A|", args: "a"), "|a|")
    XCTAssertEqual(try clformat("|~5,1,0,,0W|", args: "a"), "|a|")
    XCTAssertEqual(try clformat("|~5,1,0,,0S|", args: 7), "|7|")
    XCTAssertEqual(try clformat("|~5,1,0,,1A|", args: "a"), "|a|")
    XCTAssertEqual(try clformat("|~5,1,0,,3A|", args: "a"), "|a  |")
  }

  func testTabulationWithoutTabsize() throws {
    // With a tab size of 0, tabs count as a single column
    XCTAssertEqual(try clformat("\t~5T", tabsize: 0), "\t    ")
    XCTAssertEqual(try clformat("\t~5T", tabsize: -4), "\t    ")
  }
  
  // MARK: - Thread safety
  
  /// Collects results from concurrently running closures.
  private final class Collector: @unchecked Sendable {
    private let lock = NSLock()
    private var results: [String] = []
    
    func add(_ result: String) {
      self.lock.lock()
      self.results.append(result)
      self.lock.unlock()
    }
    
    var all: [String] {
      self.lock.lock()
      defer { self.lock.unlock() }
      return self.results
    }
  }
  
  func testDefaultConfigurationIsUsedByClformat() throws {
    let original = CLFormatConfig.default
    defer { CLFormatConfig.default = original }
    XCTAssertEqual(try clformat("~A", arguments: [nil]), "nil")
    CLFormatConfig.default.nilRepresentation = "null"
    XCTAssertEqual(try clformat("~A", arguments: [nil]), "null")
    // An explicit configuration wins over the default; `String` initializers do not use it
    XCTAssertEqual(try clformat("~A", config: CLFormatConfig.standard, arguments: [nil]), "nil")
    XCTAssertEqual(try String(control: "~A", arguments: [nil]), "nil")
    XCTAssertEqual(CLFormatConfig.standard.nilRepresentation, "nil")
  }
  
  func testDefaultConfigurationIsThreadSafe() throws {
    // The default configuration used to be an unsynchronized global variable, which
    // is a data race (reported by the thread sanitizer) when changed during formatting.
    let original = CLFormatConfig.default
    defer { CLFormatConfig.default = original }
    var alpha = CLFormatConfig.standard
    alpha.nilRepresentation = "alpha"
    var beta = CLFormatConfig.standard
    beta.nilRepresentation = "beta"
    let (configA, configB) = (alpha, beta)
    let collector = Collector()
    DispatchQueue.concurrentPerform(iterations: 8) { worker in
      for i in 0..<500 {
        if worker % 4 == 0 {
          CLFormatConfig.default = i % 2 == 0 ? configA : configB
        } else {
          collector.add((try? clformat("~A", arguments: [nil])) ?? "<error>")
        }
      }
    }
    let results = collector.all
    XCTAssertEqual(results.count, 6 * 500)
    XCTAssertTrue(Set(results).isSubset(of: ["nil", "alpha", "beta"]), "\(Set(results))")
  }
  
  func testSharedControlCanBeUsedFromMultipleThreads() throws {
    // A parsed control is immutable and can be formatted concurrently from several threads
    let control = try CLControl(string: "~D file~:P: ~{~A~^, ~}; ~8@A|")
    let failures = Collector()
    DispatchQueue.concurrentPerform(iterations: 8) { worker in
      for i in 0..<300 {
        let count = (worker * 7 + i) % 5
        let items = (0..<count).map { "item\(worker)-\($0)" }
        let tag = "t\(i)"
        let expected = "\(count) file\(count == 1 ? "" : "s"): " +
                       items.joined(separator: ", ") + "; " +
                       String(repeating: " ", count: max(8 - tag.count, 0)) + tag + "|"
        let actual = (try? control.format(args: count, items, tag)) ?? "<error>"
        if actual != expected {
          failures.add("\(actual) != \(expected)")
        }
      }
    }
    XCTAssertEqual(failures.all, [])
  }
  
  func testPublicTypesAreSendable() throws {
    // Compile-time check: these types are shared between threads, e.g. as thrown errors,
    // or as part of parsed controls that are formatted from several threads
    func requireSendable<T: Sendable>(_ type: T.Type) {}
    // Configuration
    requireSendable(CLFormatConfig.self)
    // Parsed controls and their components
    requireSendable(CLControl.self)
    requireSendable(CLControl.Component.self)
    requireSendable(Directive.self)
    requireSendable((any DirectiveSpecifier).self)
    requireSendable(StandardDirectiveSpecifier.self)
    requireSendable(Parameters.self)
    requireSendable(Parameter.self)
    requireSendable(Modifiers.self)
    // Formatting context and results
    requireSendable(Context.self)
    requireSendable(Context.History.self)
    requireSendable(Instruction.self)
    // Errors and values
    requireSendable(CLFormatError.self)
    requireSendable(CLControlError.self)
    requireSendable(Currency.self)
    requireSendable(Number.self)
  }
}

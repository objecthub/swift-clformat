//
//  CLFormatDirectiveTests.swift
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

private struct Plain: CustomStringConvertible, CustomDebugStringConvertible {
  var description: String {
    return "plain"
  }
  var debugDescription: String {
    return "debug"
  }
}

private struct DescriptionOnly: CustomStringConvertible {
  var description: String {
    return "description"
  }
}

private struct Opaque {
  let value = 7
}

///
/// Tests for the variants of the standard directives that are not covered by the main test
/// suite: modifiers, parameters, argument types, and the less common directives.
///
final class CLFormatDirectiveTests: XCTestCase {

  // MARK: - ~A, ~W, ~S

  func testAsciiArgumentTypes() throws {
    XCTAssertEqual(try clformat("~A", args: Plain()), "plain")
    XCTAssertEqual(try clformat("~:A", args: Plain()), "debug")
    XCTAssertEqual(try clformat("~A", args: DescriptionOnly()), "description")
    XCTAssertEqual(try clformat("~:A", args: DescriptionOnly()), "description")
    XCTAssertEqual(try clformat("~A", args: Opaque()), "Opaque(value: 7)")
    XCTAssertEqual(try clformat("~A", args: Optional(5) as Int?), "5")
    XCTAssertEqual(try clformat("~A", args: true), "true")
    XCTAssertEqual(try clformat("~A", args: "x" as Character), "x")
    XCTAssertEqual(try clformat("~A|~A", args: nil, nil), "nil|nil")
  }

  func testWrite() throws {
    XCTAssertEqual(try clformat("~W", args: 42), "42")
    XCTAssertEqual(try clformat("~W", args: "text"), "text")
    XCTAssertEqual(try clformat("~:W", args: "text"), "\"text\"")
    XCTAssertEqual(try clformat("~W", args: Plain()), "plain")
    XCTAssertEqual(try clformat("~:W", args: Plain()), "debug")
    XCTAssertEqual(try clformat("~W", args: Opaque()), "Opaque(value: 7)")
    XCTAssertEqual(try clformat("~W", args: nil), "nil")
    XCTAssertEqual(try clformat("|~6W|~6@W|", args: "ab", "cd"), "|ab    |    cd|")
    XCTAssertEqual(try clformat("|~6,,,'*W|", args: "ab"), "|ab****|")
    XCTAssertEqual(try clformat("|~4,,,,3W|", args: "abcdef"), "|ab…|")
  }

  func testSexpr() throws {
    XCTAssertEqual(try clformat("~S", args: "text"), "\"text\"")
    XCTAssertEqual(try clformat("~S", args: "a\"b"), "\"a\\\"b\"")
    XCTAssertEqual(try clformat("~S", args: "a\\b"), "\"a\\\\b\"")
    XCTAssertEqual(try clformat("~S", args: "a\u{7}\u{8}\r"), "\"a\\a\\b\\r\"")
    XCTAssertEqual(try clformat("~S", args: "x" as Character), "'x'")
    XCTAssertEqual(try clformat("~S", args: "\n" as Character), "'\\n'")
    XCTAssertEqual(try clformat("~S", args: 42), "42")
    XCTAssertEqual(try clformat("~S", args: Plain()), "plain")
    XCTAssertEqual(try clformat("~:S", args: Plain()), "debug")
    XCTAssertEqual(try clformat("~S", args: Opaque()), "Opaque(value: 7)")
    XCTAssertEqual(try clformat("~S", args: nil), "nil")
    XCTAssertEqual(try clformat("|~8S|~8@S|", args: "ab", "cd"), "|\"ab\"    |    \"cd\"|")
  }

  // MARK: - ~R

  func testRadixWithParameters() throws {
    XCTAssertEqual(try clformat("~2R", args: 5), "101")
    XCTAssertEqual(try clformat("~16R", args: 255), "ff")
    XCTAssertEqual(try clformat("~16+R", args: 255), "FF")
    XCTAssertEqual(try clformat("~16R", args: -255), "-ff")
    XCTAssertEqual(try clformat("~36R", args: 35), "z")
    XCTAssertEqual(try clformat("~16,8,'0R", args: 255), "000000ff")
    XCTAssertEqual(try clformat("~16,8R", args: 255), "      ff")
    XCTAssertEqual(try clformat("~8@R", args: 255), "+377")
    XCTAssertEqual(try clformat("~16,,,' ,2:R", args: 0xCAFE), "ca fe")
    XCTAssertEqual(try clformat("~16:R", args: 0xCAFE), "c,afe", "the default group size is 3")
  }

  func testRadixTenWithParameters() throws {
    XCTAssertEqual(try clformat("~10R", args: 1234567), "1234567")
    XCTAssertEqual(try clformat("~10,10R", args: 1234567), "   1234567")
    XCTAssertEqual(try clformat("~10,10,'0R", args: 1234567), "0001234567")
    XCTAssertEqual(try clformat("~10,,,',,3:R", args: 1234567), "1,234,567")
    XCTAssertEqual(try clformat("~10@R", args: 1234567), "+1234567")
    XCTAssertEqual(try clformat("~10:R", args: 1234567), "1,234,567")
  }

  func testNumberWords() throws {
    XCTAssertEqual(try clformat("~R", args: 0), "zero")
    XCTAssertEqual(try clformat("~R", args: 21), "twenty-one")
    XCTAssertEqual(try clformat("~R", args: -3), "minus three")
    XCTAssertEqual(try clformat("~R", args: 1.5), "one point five")
    XCTAssertEqual(try clformat("~:R", args: 1), "1st")
    XCTAssertEqual(try clformat("~:R", args: 2), "2nd")
    XCTAssertEqual(try clformat("~:R", args: 3), "3rd")
    XCTAssertEqual(try clformat("~:R", args: 4), "4th")
    XCTAssertEqual(try clformat("~:R", args: 11), "11th")
    XCTAssertEqual(try clformat("~@R", args: 14), "XIV")
    let german = Locale(identifier: "de_DE")
    XCTAssertEqual(try clformat("~+R", locale: german, args: 3), "drei")
    XCTAssertEqual(try clformat("~:+R", locale: german, args: 3), "3.")
  }

  // MARK: - ~B, ~O, ~X, ~D

  func testNonDecimalIntegerTypes() throws {
    XCTAssertEqual(try clformat("~B", args: Int16(5)), "101")
    XCTAssertEqual(try clformat("~B", args: Int32(5)), "101")
    XCTAssertEqual(try clformat("~B", args: Int64(5)), "101")
    XCTAssertEqual(try clformat("~B", args: UInt(5)), "101")
    XCTAssertEqual(try clformat("~B", args: UInt8(5)), "101")
    XCTAssertEqual(try clformat("~B", args: UInt16(5)), "101")
    XCTAssertEqual(try clformat("~B", args: UInt32(5)), "101")
    XCTAssertEqual(try clformat("~X", args: UInt64.max), "ffffffffffffffff")
    XCTAssertEqual(try clformat("~X", args: Int.min), "-8000000000000000")
    XCTAssertEqual(try clformat("~@X", args: 255), "+ff")
    XCTAssertEqual(try clformat("~8,'0B", args: 5), "00000101")
    XCTAssertEqual(try clformat("~O", args: 8), "10")
    XCTAssertEqual(try clformat("~:O", args: 0o12345670), "1234 5670")
    XCTAssertEqual(try clformat("~:X", args: 0xCAFEBABE), "ca:fe:ba:be")
    XCTAssertEqual(try clformat("~+X", args: 0xCAFE), "CAFE")
  }

  func testDecimalWithGrouping() throws {
    XCTAssertEqual(try clformat("~D", args: 1234567), "1234567")
    XCTAssertEqual(try clformat("~:D", args: 1234567), "1,234,567")
    XCTAssertEqual(try clformat("~,,'.:D", args: 1234567), "1.234.567")
    XCTAssertEqual(try clformat("~,,' ,4:D", args: 123456789), "1 2345 6789")
    XCTAssertEqual(try clformat("~12:@D", args: 1234567), "  +1,234,567")
    XCTAssertEqual(try clformat("~D", args: UInt64.max), "18446744073709551615")
    XCTAssertEqual(try clformat("~D", args: Int.min), "-9223372036854775808")
    XCTAssertEqual(try clformat("~D", args: Decimal(string: "1234.5")!), "1234.5")
  }

  // MARK: - ~$, ~F with grouping parameters

  func testMoneyGrouping() throws {
    XCTAssertEqual(try clformat("~,,,,,'_,3$", args: 1234567.891), "1_234_567.89")
    XCTAssertEqual(try clformat("~,,,,,,3$", args: 1234567.891), "1,234,567.89")
    XCTAssertEqual(try clformat("~,,,,,'_$", args: 1234567.891), "1_234_567.89")
    XCTAssertEqual(try clformat("~,,,,,,2$", args: 1234567.891), "1,23,45,67.89")
    XCTAssertEqual(try clformat("~,2,,,'€,'.,3$", args: 1234567.891), "€1.234.567.89")
  }

  func testLocalizedFloats() throws {
    let german = Locale(identifier: "de_DE")
    XCTAssertEqual(try clformat("~,2+F", locale: german, args: 1234.5), "1234,50")
    XCTAssertEqual(try clformat("~,2:+F", locale: german, args: 1234.5), "1.234,50")
    XCTAssertEqual(try clformat("~,2+E", locale: german, args: 1234.5), "1,23E+3")
    XCTAssertEqual(try clformat("~+$", locale: german, args: 1234.5).replacingOccurrences(of: "\u{a0}", with: " "),
                   "1234,50 €")
  }

  // MARK: - ~%, ~&, ~|, ~~

  func testNewlines() throws {
    XCTAssertEqual(try clformat("a~%b"), "a\nb")
    XCTAssertEqual(try clformat("a~3%b"), "a\n\n\nb")
    XCTAssertEqual(try clformat("a~0%b"), "ab")
    XCTAssertEqual(try clformat("a~~b"), "a~b")
    XCTAssertEqual(try clformat("a~3~b"), "a~~~b")
  }

  func testFreshLine() throws {
    XCTAssertEqual(try clformat("abc~&def"), "abc\ndef")
    XCTAssertEqual(try clformat("~&def"), "def", "at the start of the output")
    XCTAssertEqual(try clformat("abc~%~&def"), "abc\ndef", "already at the start of a line")
    XCTAssertEqual(try clformat("abc~2&def"), "abc\n\ndef")
    XCTAssertEqual(try clformat("abc~%~2&def"), "abc\n\ndef")
    XCTAssertEqual(try clformat("~2&def"), "\ndef")
    XCTAssertEqual(try clformat("abc~0&def"), "abcdef")
  }

  func testPageSeparator() throws {
    XCTAssertEqual(try clformat("a~|b"), "a\u{12}b")
    XCTAssertEqual(try clformat("a~3|b"), "a\u{12}\u{12}\u{12}b")
  }

  func testLineContinuation() throws {
    XCTAssertEqual(try clformat("a~\n   b"), "ab")
    XCTAssertEqual(try clformat("a~:\n   b"), "a   b")
    XCTAssertEqual(try clformat("a~@\n   b"), "a\nb")
  }

  // MARK: - ~P

  func testPlural() throws {
    XCTAssertEqual(try clformat("~D file~:P", args: 1), "1 file")
    XCTAssertEqual(try clformat("~D file~:P", args: 0), "0 files")
    XCTAssertEqual(try clformat("~D file~:P", args: 2), "2 files")
    XCTAssertEqual(try clformat("~D famil~:@P", args: 1), "1 family")
    XCTAssertEqual(try clformat("~D famil~:@P", args: 3), "3 families")
    XCTAssertEqual(try clformat("~D item~P", args: 2, 1), "2 item")
    XCTAssertEqual(try clformat("~D item~P", args: 2, 5), "2 items")
    XCTAssertEqual(try clformat("~D item~:P", args: 1.0), "1 items", "floating-point is never 1")
  }

  // MARK: - ~*

  func testArgumentNavigation() throws {
    XCTAssertEqual(try clformat("~A ~*~A", args: 1, 2, 3), "1 3")
    XCTAssertEqual(try clformat("~A ~2*~A", args: 1, 2, 3, 4), "1 4")
    XCTAssertEqual(try clformat("~A ~A ~:*~A", args: 1, 2), "1 2 2")
    XCTAssertEqual(try clformat("~A ~A ~A ~2:*~A", args: 1, 2, 3), "1 2 3 2")
    XCTAssertEqual(try clformat("~A ~A ~0@*~A", args: 1, 2), "1 2 1")
    XCTAssertEqual(try clformat("~A ~A ~1@*~A", args: 1, 2), "1 2 2")
    XCTAssertEqual(try clformat("~3@*~A", args: 1, 2, 3, 4), "4")
    XCTAssertEqual(try clformat("~@*~A", args: 1, 2), "1", "jump to the first argument by default")
    XCTAssertEqual(try clformat("~0*~A", args: 1), "1")
    XCTAssertEqual(try clformat("~D~:*~D", args: 7), "77")
    // Backing up beyond the first argument is an error
    XCTAssertThrowsError(try clformat("~D~:*~:*~D", args: 7, 8))
  }

  func testParametersFromArguments() throws {
    XCTAssertEqual(try clformat("|~vA|", args: 5, "x"), "|x    |")
    XCTAssertEqual(try clformat("|~vA|", args: nil, "x"), "|x|", "nil is an omitted parameter")
    XCTAssertEqual(try clformat("|~v,vA|", args: 5, 3, "x"), "|x      |", "increments of 3")
    XCTAssertEqual(try clformat("|~,,,vA|", args: "*", "x") , "|x|")
    XCTAssertEqual(try clformat("|~8,,,vA|", args: "*", "x"), "|x*******|")
    XCTAssertEqual(try clformat("|~v,,,vA|", args: 4, Character("-"), "x"), "|x---|")
    XCTAssertEqual(try clformat("~#D ~D", args: 5, 6), " 5 6", "# is the number of remaining arguments")
    XCTAssertEqual(try clformat("~#,'0D", args: 7, 8), "07")
  }

  // MARK: - ~(, ~[, ~{, ~^

  func testCaseConversion() throws {
    XCTAssertEqual(try clformat("~(~A~)", args: "Hello WORLD"), "hello world")
    XCTAssertEqual(try clformat("~:(~A~)", args: "hello wORLD"), "Hello World")
    XCTAssertEqual(try clformat("~@(~A~)", args: "hello world"), "Hello world")
    XCTAssertEqual(try clformat("~:@(~A~)", args: "Hello World"), "HELLO WORLD")
    XCTAssertEqual(try clformat("~(~)"), "")
    XCTAssertEqual(try clformat("~:@(abc ~D~)", args: 5), "ABC 5")
    XCTAssertEqual(try clformat("a~(B~A~)c", args: "D"), "abdc")
    XCTAssertEqual(try clformat("~(a~(B~)C~)"), "abc", "nested conversions")
  }

  func testEscapingConversion() throws {
    XCTAssertEqual(try clformat("~+(~A~)", args: "a\tb\nc\"d"), "a\\tb\\nc\\\"d")
    XCTAssertEqual(try clformat("~@+(~A~)", args: "Ünïcödé"), "Unicode")
    XCTAssertEqual(try clformat("~:+(~A~)", args: "© 2026"), "&copy; 2026")
    XCTAssertEqual(try clformat("~:@+(~A~)", args: "<a & b>"), "&lt;a &amp; b&gt;")
    XCTAssertEqual(try clformat("~:@+(~A~)", args: "say \"x\""), "say &quot;x&quot;")
  }

  func testConditionals() throws {
    XCTAssertEqual(try clformat("~[a~;b~;c~]", args: 0), "a")
    XCTAssertEqual(try clformat("~[a~;b~;c~]", args: 2), "c")
    XCTAssertEqual(try clformat("~[a~;b~;c~]", args: 3), "")
    XCTAssertEqual(try clformat("~[a~;b~;c~]", args: -1), "")
    XCTAssertEqual(try clformat("~[a~;b~:;other~]", args: 5), "other")
    XCTAssertEqual(try clformat("~1[a~;b~;c~]", args: "unused"), "b", "the index is a parameter")
    XCTAssertEqual(try clformat("~#[none~;one: ~A~;two: ~A and ~A~]", args: "x", "y"), "two: x and y")
    XCTAssertEqual(try clformat("~[a~;b~]~A", args: 1, "next"), "bnext")
    XCTAssertEqual(try clformat("~[~]x", args: 0), "x")
  }

  func testBooleanAndNilConditionals() throws {
    XCTAssertEqual(try clformat("~:[nil~;value~]", args: nil), "nil")
    XCTAssertEqual(try clformat("~:[nil~;value~]", args: 0), "value")
    XCTAssertEqual(try clformat("~:[nil~;value~]", args: "x"), "value")
    XCTAssertEqual(try clformat("~+[no~;yes~]", args: false), "no")
    XCTAssertEqual(try clformat("~+[no~;yes~]", args: true), "yes")
    XCTAssertEqual(try clformat("~+[no~;yes~]", args: 5), "yes", "non-booleans select the second branch")
    XCTAssertEqual(try clformat("~+[no~;yes~]", args: nil), "yes")
    XCTAssertEqual(try clformat("~@[<~A>~]", args: 5), "<5>")
    XCTAssertEqual(try clformat("a~@[<~A>~]b", args: nil), "ab")
    XCTAssertEqual(try clformat("~@[<~A>~] ~A", args: nil, "next"), " next", "nil is consumed")
  }

  func testIterations() throws {
    XCTAssertEqual(try clformat("~{~A~^,~}", args: [1, 2, 3]), "1,2,3")
    XCTAssertEqual(try clformat("~{~A~^,~}", args: [Int]()), "")
    XCTAssertEqual(try clformat("~2{~A~^,~}", args: [1, 2, 3, 4]), "1,2")
    XCTAssertEqual(try clformat("~0{~A~}", args: [1, 2]), "")
    XCTAssertEqual(try clformat("~{x~:}", args: [Int]()), "x", "~:} forces one iteration")
    XCTAssertEqual(try clformat("~{x~A~:}", args: [1, 2]), "x1x2")
    XCTAssertEqual(try clformat("~@{~A~^,~}", args: 1, 2, 3), "1,2,3")
    XCTAssertEqual(try clformat("~A ~@{~A~^,~}", args: 0, 1, 2), "0 1,2")
    XCTAssertEqual(try clformat("~{~A~}", args: ["a", "b"], "c"), "ab")
    XCTAssertEqual(try clformat("~{~}", args: "<~A>", ["x", "y"] as [Any?]),
                   "<x><y>", "the control string is taken from the arguments")
    XCTAssertEqual(try clformat("~{~A ~A~^; ~}", args: [1, 2, 3, 4]), "1 2; 3 4")
    XCTAssertEqual(try clformat("[~{~A~}]", args: 1...3), "[123]", "any sequence works")
  }

  func testIterationsOverSublists() throws {
    XCTAssertEqual(try clformat("~:{<~A,~A>~}", args: [[1, 2], [3, 4]]), "<1,2><3,4>")
    XCTAssertEqual(try clformat("~:{<~A>~}", args: [[1, 2], [3, 4]]), "<1><3>")
    XCTAssertEqual(try clformat("~:{<~A>~}", args: [1, [2, 3], 4]), "<1><2><4>",
                   "elements that are not sequences are arguments by themselves")
    XCTAssertEqual(try clformat("~1:{<~A>~}", args: [[1, 2], [3, 4]]), "<1>", "iteration cap")
    XCTAssertEqual(try clformat("~:@{<~A,~A>~}", args: [1, 2], [3, 4]), "<1,2><3,4>")
    // Everything after `~^` is skipped if there are no more arguments, including the `>`
    XCTAssertEqual(try clformat("~:{<~A~^,~A>~}", args: [[1, 2], [3]]), "<1,2><3")
    XCTAssertEqual(try clformat("~:{~A~:^,~}", args: [[1], [2], [3]]), "1,2,3")
    XCTAssertThrowsError(try clformat("~:{<~A>~}", args: [[Int]()]), "empty sublists have no arguments")
  }

  func testUpAndOut() throws {
    XCTAssertEqual(try clformat("~{~A~^;~}", args: [1, 2, 3]), "1;2;3")
    XCTAssertEqual(try clformat("~{~A~0^;~}", args: [1, 2, 3]), "123", "zero stops the body")
    XCTAssertEqual(try clformat("~{~A~1^;~}", args: [1, 2, 3]), "1;2;3;", "non-zero continues")
    XCTAssertEqual(try clformat("~{~A~1,1^;~}", args: [1, 2]), "12", "equal parameters stop")
    XCTAssertEqual(try clformat("~{~A~1,2^;~}", args: [1, 2]), "1;2;", "different ones continue")
    XCTAssertEqual(try clformat("~{~A~1,2,3^;~}", args: [1, 2]), "12", "ascending parameters stop")
    XCTAssertEqual(try clformat("~{~A~3,2,1^;~}", args: [1, 2]), "1;2;", "others continue")
    XCTAssertEqual(try clformat("~{~A~2,2,2^;~}", args: [1, 2]), "12")
    XCTAssertEqual(try clformat("~:{~A~0:^;~}", args: [[1], [2]]), "1", "~:^ leaves the iteration")
    XCTAssertEqual(try clformat("~:{~A~:^;~}", args: [[1], [2]]), "1;2")
    XCTAssertEqual(try clformat("~{~A~#^;~}", args: [1, 2]), "1;2", "# is the number of arguments")
  }

  func testUpAndOutInsideJustification() throws {
    // `~:^` cannot be used in the sections of a justification directive
    XCTAssertThrowsError(try clformat("~10<a~0:^b~>")) { error in
      XCTAssertEqual((error as? CLFormatError)?.description,
                     "malformed directive ~:^ in control string")
    }
    // ... but `~^` can: it drops its section and all following sections
    XCTAssertEqual(try clformat("|~10<a~0^b~>|"), "||")
    XCTAssertEqual(try clformat("|~10<a~;b~0^c~>|"), "|         a|")
  }

  func testIndirection() throws {
    XCTAssertEqual(try clformat("~?", args: "<~A>", ["x"] as [Any?]), "<x>")
    XCTAssertEqual(try clformat("~@?", args: "<~A>", "x"), "<x>")
    XCTAssertEqual(try clformat("~@? ~A", args: "<~A>", "x", "y"), "<x> y")
    XCTAssertEqual(try clformat("~? ~A", args: "<~A>", ["x"] as [Any?], "y"), "<x> y")
    XCTAssertThrowsError(try clformat("~?", args: 5, [1] as [Any?]))
    XCTAssertThrowsError(try clformat("~@?", args: 5))
  }

  // MARK: - Closing directives

  func testClosingDirectivesCannotBeApplied() throws {
    // They are only valid as part of composite directives, but a control can be created
    // manually
    let specifiers: [(StandardDirectiveSpecifier, String)] = [
      (.separator, "~;"), (.conversionEnd, "~)"), (.conditionalEnd, "~]"),
      (.iterationEnd, "~}"), (.justificationEnd, "~>")]
    for (specifier, name) in specifiers {
      let directive = Directive(parameters: Parameters(), modifiers: [], specifier: specifier)
      let control = CLControl(components: [.directive(directive)])
      XCTAssertThrowsError(try control.format(), name) { error in
        XCTAssertEqual((error as? CLFormatError)?.description,
                       "unsupported directive \(name) in control string")
      }
    }
  }

  // MARK: - ~C

  func testCharacters() throws {
    XCTAssertEqual(try clformat("~C", args: "x" as Character), "x")
    XCTAssertEqual(try clformat("~C~C", args: "a", "b"), "ab")
    XCTAssertEqual(try clformat("~C", args: "é"), "é")
    XCTAssertEqual(try clformat("~@C", args: "x" as Character), "\\u{78}")
    XCTAssertThrowsError(try clformat("~C", args: "xy"))
    XCTAssertThrowsError(try clformat("~C", args: 65))
  }

  // MARK: - ~T

  func testTabulation() throws {
    XCTAssertEqual(try clformat("~10T|"), "          |")
    XCTAssertEqual(try clformat("abc~10T|"), "abc       |")
    XCTAssertEqual(try clformat("abcdefghijkl~10T|"), "abcdefghijkl |", "past the column, increment 1")
    XCTAssertEqual(try clformat("abcdefghijkl~10,5T|"), "abcdefghijkl   |")
    XCTAssertEqual(try clformat("abc~4@T|"), "abc    |")
    XCTAssertEqual(try clformat("abc~4,5@T|"), "abc       |", "4 columns, then up to a multiple of 5")
    XCTAssertEqual(try clformat("abc~0,0T|"), "abc|")
    XCTAssertEqual(try clformat("a~%bc~6T|"), "a\nbc    |", "columns restart after newlines")
  }
}

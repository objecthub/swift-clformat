//
//  CLFormatErrorTests.swift
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
/// Tests for the errors reported while parsing control strings (`CLControlError`) and
/// while formatting (`CLFormatError`).
///
final class CLFormatErrorTests: XCTestCase {

  /// Asserts that parsing/formatting `control` fails with a `CLControlError` with the given
  /// description.
  private func assertControlError(_ control: String,
                                  _ args: Any?...,
                                  description: String,
                                  file: StaticString = #filePath,
                                  line: UInt = #line) {
    XCTAssertThrowsError(try clformat(control, arguments: args), control,
                         file: file, line: line) { error in
      guard let error = error as? CLControlError else {
        return XCTFail("\(control): unexpected error \(error)", file: file, line: line)
      }
      XCTAssertEqual(error.description, description, control, file: file, line: line)
      XCTAssertEqual(error.errorDescription, description, file: file, line: line)
      XCTAssertEqual(error.failureReason, "syntax error in control string",
                     file: file, line: line)
    }
  }

  /// Asserts that formatting `control` fails with a `CLFormatError` with the given description.
  private func assertFormatError(_ control: String,
                                 _ args: Any?...,
                                 description: String,
                                 file: StaticString = #filePath,
                                 line: UInt = #line) {
    XCTAssertThrowsError(try clformat(control, arguments: args), control,
                         file: file, line: line) { error in
      guard let error = error as? CLFormatError else {
        return XCTFail("\(control): unexpected error \(error)", file: file, line: line)
      }
      XCTAssertEqual(error.description, description, control, file: file, line: line)
      XCTAssertEqual(error.errorDescription, description, file: file, line: line)
      XCTAssertEqual(error.localizedDescription, description, file: file, line: line)
    }
  }

  // MARK: - Control string errors

  func testPrematureEndOfControl() throws {
    assertControlError("~", description: "premature end of control")
    assertControlError("abc~", description: "premature end of control")
    assertControlError("~5", description: "premature end of control")
    assertControlError("~5,", description: "premature end of control")
    assertControlError("~'", description: "premature end of control")
    assertControlError("~:@", description: "premature end of control")
    assertControlError("~v", description: "premature end of control")
  }

  func testDuplicateModifiers() throws {
    assertControlError("~::D", 1, description: "duplicate modifier :")
    assertControlError("~@@D", 1, description: "duplicate modifier @")
    assertControlError("~++D", 1, description: "duplicate modifier +")
    assertControlError("~:@:D", 1, description: "duplicate modifier :")
  }

  func testMalformedNumericParameters() throws {
    assertControlError("~-D", 1, description: "malformed numeric parameter: -D")
    assertControlError("~5,-xA", "a", description: "malformed numeric parameter: -x")
    assertControlError("~99999999999999999999D", 1,
                       description: "malformed numeric parameter: 99999999999999999999")
    assertControlError("~-99999999999999999999D", 1,
                       description: "malformed numeric parameter: -99999999999999999999")
  }

  func testUnknownDirectives() throws {
    assertControlError("~Q", description: "unknown directive ~Q")
    assertControlError("abc ~Z def", description: "unknown directive ~Z")
    assertControlError("~3,4Q", description: "unknown directive ~Q")
    assertControlError("~:@!", description: "unknown directive ~!")
  }

  func testMalformedCompositeDirectives() throws {
    assertControlError("~(abc", description: "malformed conversion syntax ~(...~)")
    assertControlError("~[abc", description: "malformed conditional syntax ~[...~]")
    assertControlError("~[a~;b~:;c~;d~]",
                       description: "malformed conditional syntax ~[...~:;...~]")
    assertControlError("~{abc", description: "malformed iteration syntax ~{...~}")
    assertControlError("~<abc", description: "malformed justification syntax ~<...~>")
    assertControlError("~<a~;b~:;c~>",
                       description: "malformed justification syntax ~<...~:;...~>")
    assertControlError("~1,2,3,4,5<a~;b~>",
                       description: "malformed justification syntax ~,,,,X<...~>")
  }

  func testMisplacedDirectives() throws {
    assertControlError("a~]", description: "directive ~] in unsupported place")
    assertControlError("a~;b", description: "directive ~; in unsupported place")
    assertControlError("a~)", description: "directive ~) in unsupported place")
    assertControlError("a~}", description: "directive ~} in unsupported place")
    // Closing directives of nested constructs must match
    assertControlError("~(a~]b~)", description: "malformed conversion syntax ~(...~)")
    assertControlError("~{a~)b~}", description: "malformed iteration syntax ~{...~}")
  }

  func testMalformedClosingDirectives() throws {
    // Closing directives accept neither parameters nor (most) modifiers
    assertControlError("~(a~1)", description: "malformed directive ~1)")
    assertControlError("~(a~:)", description: "malformed directive ~:)")
    assertControlError("~[a~:@]", description: "malformed directive ~:@]")
    assertControlError("~[a~3]", description: "malformed directive ~3]")
    assertControlError("~{a~@}", description: "malformed directive ~@}")
    assertControlError("~<a~:>", description: "malformed directive ~:>")
    assertControlError("~[a~1;b~]", description: "malformed directive ~1;")
    assertControlError("~[a~@;b~]", description: "malformed directive ~@;")
    assertControlError("~:@\n", description: "malformed directive ~:@\\n")
  }

  func testControlErrorDescriptions() throws {
    // Cases that cannot be triggered by the built-in directive parsers
    XCTAssertEqual(CLControlError.malformedParameter.description, "malformed parameter")
    XCTAssertEqual(CLControlError.unsupportedDirective("~Y").description,
                   "unsupported directive ~Y")
    XCTAssertEqual(CLControlError.unsupportedDirective("~Y").errorDescription,
                   "unsupported directive ~Y")
    XCTAssertEqual(CLControlError.malformedParameter.localizedDescription,
                   "malformed parameter")
    XCTAssertEqual(CLControlError.prematureEndOfControl.failureReason,
                   "syntax error in control string")
  }

  func testParseErrorsAreReportedByControlInitializers() throws {
    XCTAssertThrowsError(try CLControl(string: "~Q")) { error in
      XCTAssertEqual((error as? CLControlError)?.description, "unknown directive ~Q")
    }
    XCTAssertThrowsError(try String(control: "~(", args: 1)) { error in
      XCTAssertTrue(error is CLControlError, "\(error)")
    }
    // Control strings are parsed even if the arguments are not used
    XCTAssertThrowsError(try clformat("fine ~Q"))
  }

  // MARK: - Formatting errors

  func testMissingArguments() throws {
    assertFormatError("~A", description: "missing argument")
    assertFormatError("~D", description: "missing argument")
    assertFormatError("~A ~A", 1, description: "missing argument")
    assertFormatError("~{~A~}", description: "missing argument")
    assertFormatError("~vA", description: "missing argument")
  }

  func testExpectedNumberArguments() throws {
    assertFormatError("~D", "abc",
                      description: "expected argument 0 to be a number; instead it is abc")
    assertFormatError("~A ~F", "x", "y",
                      description: "expected argument 1 to be a number; instead it is y")
    assertFormatError("~B", true,
                      description: "expected argument 0 to be a number; instead it is true")
    assertFormatError("~[a~;b~]", "x",
                      description: "expected argument 0 to be a number; instead it is x")
  }

  func testExpectedSequenceArguments() throws {
    assertFormatError("~{~A~}", 5,
                      description: "expected argument 0 to be a sequence; instead it is 5")
    assertFormatError("~:{~A~}", 5,
                      description: "expected argument 0 to be a sequence; instead it is 5")
    assertFormatError("~? ~A", "~A", 1,
                      description: "expected argument 1 to be a sequence; instead it is 1")
  }

  func testArgumentsCannotBeUsedAsParameters() throws {
    assertFormatError("~vA", "abc", "x",
                      description: "cannot use argument 0 as parameter: abc")
    assertFormatError("~vA", [1, 2], "x",
                      description: "cannot use argument 0 as parameter: [1, 2]")
    assertFormatError("~vA", Parameters.maxNumber + 1, "x",
                      description: "cannot use argument 0 as parameter: " +
                                   "\(Parameters.maxNumber + 1)")
  }

  func testArgumentOutOfRange() throws {
    assertFormatError("~5*", 1,
                      description: "cannot access argument 5; only 1 arguments in total")
    assertFormatError("~:*", 1,
                      description: "cannot access argument -1; only 1 arguments in total")
    assertFormatError("~A~2:*", 1,
                      description: "cannot access argument -1; only 1 arguments in total")
    assertFormatError("~5@*", 1,
                      description: "cannot access argument 5; only 1 arguments in total")
  }

  func testParameterTypeErrors() throws {
    assertFormatError("~'xD", 1,
                      description: "expected parameter 0 to be a number, instead it is 'x")
    assertFormatError("~-1A", "a",
                      description: "expected parameter 0 to be a non-negative number, " +
                                   "instead it is -1")
    assertFormatError("~,,,5A", "a",
                      description: "expected parameter 3 to be a character, instead it is 5")
    assertFormatError("~vA", "xy",
                      description: "cannot use argument 0 as parameter: xy")
  }

  func testMalformedAndUnsupportedDirectives() throws {
    assertFormatError("~:@[a~]", 1, description: "malformed directive ~:@[ in control string")
    assertFormatError("~:[a~;b~;c~]", 1, description: "malformed directive ~:[ in control string")
    assertFormatError("~:[a~:;b~]", 1, description: "malformed directive ~:[ in control string")
    assertFormatError("~+[a~]", true, description: "malformed directive ~+[ in control string")
    assertFormatError("~@[a~;b~]", 1, description: "malformed directive ~@[ in control string")
    assertFormatError("~:@*", 1, description: "malformed directive ~:@* in control string")
    assertFormatError("~1,2,3,4^", description: "malformed directive ~1,2,3,4^ in control string")
    assertFormatError("~:@R", 5, description: "unsupported directive ~:@R in control string")
  }

  func testNumbersCannotBeRepresentedInRadix() throws {
    // Floating-point numbers are not an error for ~B, ~O, and ~X; they are printed like with ~D
    XCTAssertEqual(try clformat("~B", args: 1.5), "1.5")
    XCTAssertEqual(try clformat("~O", args: 1.5), "1.5")
    XCTAssertEqual(try clformat("~X", args: 1.5), "1.5")
    assertFormatError("~37R", 5, description: "cannot represent 5 with radix 37")
    assertFormatError("~1R", 5, description: "cannot represent 5 with radix 1")
  }

  func testFormatErrorDescriptions() throws {
    // Complete list of all cases, including the ones that built-in directives never throw
    let cases: [(CLFormatError, String, String)] = [
      (.malformedDirective("~Q"),
       "malformed directive ~Q in control string",
       "illegal combination of directive parameters"),
      (.unsupportedDirective("~Q"),
       "unsupported directive ~Q in control string",
       "implementation limitation"),
      (.argumentOutOfRange(3, 2),
       "cannot access argument 3; only 2 arguments in total",
       "illegal argument"),
      (.missingArgument,
       "missing argument",
       "too few arguments"),
      (.expectedNumberArgument(1, "x"),
       "expected argument 1 to be a number; instead it is x",
       "argument is expected to be a number"),
      (.expectedSequenceArgument(2, 7),
       "expected argument 2 to be a sequence; instead it is 7",
       "argument is expected to be a sequence"),
      (.cannotUseArgumentAsParameter(0, "abc"),
       "cannot use argument 0 as parameter: abc",
       "illegal argument"),
      (.missingNumberParameter(2),
       "missing number parameter 2",
       "missing parameter"),
      (.expectedNumberParameter(1, "x"),
       "expected parameter 1 to be a number, instead it is x",
       "wrong parameter type"),
      (.expectedNumberParameter(1, nil),
       "expected parameter 1 to be a number, instead it is nil",
       "wrong parameter type"),
      (.expectedPositiveNumberParameter(0, -4),
       "expected parameter 0 to be a non-negative number, instead it is -4",
       "wrong parameter type"),
      (.expectedPositiveNumberParameter(0, nil),
       "expected parameter 0 to be a non-negative number, instead it is nil",
       "wrong parameter type"),
      (.missingCharacterParameter(3),
       "missing character parameter 3",
       "missing parameter"),
      (.expectedCharacterParameter(3, 5),
       "expected parameter 3 to be a character, instead it is 5",
       "wrong parameter type"),
      (.expectedCharacterParameter(3, nil),
       "expected parameter 3 to be a character, instead it is nil",
       "wrong parameter type"),
      (.missingSequenceParameter(1),
       "missing sequence parameter 1",
       "missing parameter"),
      (.expectedSequenceParameter(1, 5),
       "expected parameter 1 to be a sequence, instead it is 5",
       "wrong parameter type"),
      (.expectedSequenceParameter(1, nil),
       "expected parameter 1 to be a sequence, instead it is nil",
       "wrong parameter type"),
      (.cannotRepresentNumber(.double(2.5), 8),
       "cannot represent 2.5 with radix 8",
       "illegal radix")
    ]
    for (error, description, reason) in cases {
      XCTAssertEqual(error.description, description)
      XCTAssertEqual(error.errorDescription, description)
      XCTAssertEqual(error.localizedDescription, description)
      XCTAssertEqual(error.failureReason, reason, description)
    }
  }

  // MARK: - Errors inside composite directives

  func testErrorsInsideCompositeDirectives() throws {
    // Errors are propagated from nested directives
    assertFormatError("~{~D~}", ["a"],
                      description: "expected argument 0 to be a number; instead it is a")
    assertFormatError("~(~D~)", "a",
                      description: "expected argument 0 to be a number; instead it is a")
    assertFormatError("~[~D~]", 0, "a",
                      description: "expected argument 1 to be a number; instead it is a")
    assertFormatError("~10<~D~>", "a",
                      description: "expected argument 0 to be a number; instead it is a")
    assertFormatError("~? ~A", "~D", ["x"],
                      description: "expected argument 0 to be a number; instead it is x")
  }

  func testErrorsDoNotLeakPartialOutput() throws {
    // Formatting either succeeds completely or throws
    XCTAssertThrowsError(try clformat("abc ~A def ~D", args: "x", "y"))
    XCTAssertEqual(try clformat("abc ~A def ~D", args: "x", 5), "abc x def 5")
  }
}

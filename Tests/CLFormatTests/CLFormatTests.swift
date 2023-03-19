//
//  CLFormatTests.swift
//  CLFormatTests
//
//  Created by Matthias Zenger on 14/03/2023.
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

import XCTest
@testable import CLFormat

final class CLFormatTests: XCTestCase {
  
  func testFixedFloat() throws {
    XCTAssertEqual(try clformat("|~F|", args: 123456.78901), "|123456.78901|")
    XCTAssertEqual(try clformat("|~,2F|", args: 123456.78901), "|123456.79|")
    XCTAssertEqual(try clformat("|~15F|", args: 123456.78901), "|   123456.78901|")
    XCTAssertEqual(try clformat("|~15,2F|", args: 123456.78901), "|      123456.79|")
    XCTAssertEqual(try clformat("|~15,2@F|", args: 123456.78901), "|     +123456.79|")
    XCTAssertEqual(try clformat("|~15,2,,,'_@F|", args: 0.011), "|__________+0.01|")
    XCTAssertEqual(try clformat("|~8,3F|", args: 123456.78901), "|123456.789|")
    XCTAssertEqual(try clformat("|~8,3,0,'-F|", args: 123456.78901), "|--------|")
    XCTAssertEqual(try clformat("|~8,3,-2F|", args: 123456.78901), "|1234.568|")
  }
  
  func testSimpleJustification() throws {
    XCTAssertEqual(try clformat("|~16<foo~>|"), "|             foo|")
    XCTAssertEqual(try clformat("|~16:<foo~>|"), "|             foo|")
    XCTAssertEqual(try clformat("|~16@<foo~>|"), "|foo             |")
    XCTAssertEqual(try clformat("|~16:@<foo~>|"), "|       foo      |")
    XCTAssertEqual(try clformat("|~16<foo~;barab~>|"), "|foo        barab|")
    XCTAssertEqual(try clformat("|~16:<foo~;barab~>|"), "|    foo    barab|")
    XCTAssertEqual(try clformat("|~16@<foo~;barab~>|"), "|foo    barab    |")
    XCTAssertEqual(try clformat("|~16:@<foo~;barab~>|"), "|   foo   barab  |")
    XCTAssertEqual(try clformat("|~19<one~;two~;three~>|"), "|one    two    three|")
    XCTAssertEqual(try clformat("|~19:<one~;two~;three~>|"), "|   one   two  three|")
    XCTAssertEqual(try clformat("|~19@<one~;two~;three~>|"), "|one   two   three  |")
    XCTAssertEqual(try clformat("|~19:@<one~;two~;three~>|"), "|  one  two  three  |")
  }
  
  func testMaxcolJustification() throws {
    XCTAssertEqual(try clformat("|~8,,,,8<foobargoo~>|"), "|foobarg…|")
    XCTAssertEqual(try clformat("|~12,,,,12<foobargoo~>|"), "|   foobargoo|")
    XCTAssertEqual(try clformat("|~12,,,,12:<foobargoo~>|"), "|   foobargoo|")
    XCTAssertEqual(try clformat("|~12,,,,12@<foobargoo~>|"), "|foobargoo   |")
    XCTAssertEqual(try clformat("|~12,,,,12:@<foobargoo~>|"), "|  foobargoo |")
    XCTAssertEqual(try clformat("|~8,4,,,11<foobargoo~>|"), "|  foobargoo|")
    XCTAssertEqual(try clformat("|~8,4,,,11:<foobargoo~>|"), "|  foobargoo|")
    XCTAssertEqual(try clformat("|~8,4,,,11@<foobargoo~>|"), "|foobargoo  |")
    XCTAssertEqual(try clformat("|~8,4,,,11:@<foobargoo~>|"), "| foobargoo |")
    XCTAssertEqual(try clformat("|~8,4,,,11:@<foobargoo012~>|"), "|foobargoo0…|")
  }
  
  func testUpAndOutJustification() throws {
    
  }
}

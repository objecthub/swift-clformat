//
//  CLFormatTests.swift
//  CLFormatTests
//
//  Created by Matthias Zenger on 14/03/2023.
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
}

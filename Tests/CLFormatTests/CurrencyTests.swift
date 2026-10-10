//
//  CurrencyTests.swift
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
/// Tests for the ISO 4217 currency table and the currency-related features of directive `~$`.
///
final class CurrencyTests: XCTestCase {

  /// Locale data uses various kinds of non-breaking spaces; they are normalized for comparison.
  private func normalized(_ str: String) -> String {
    return String(str.map { $0.isWhitespace ? " " : $0 })
  }

  // MARK: - Currency table

  func testLookupByAlphabeticCode() throws {
    let euro = try XCTUnwrap(Currency(alphabeticCode: "EUR"))
    XCTAssertEqual(euro.name, "Euro")
    XCTAssertEqual(euro.alphabeticCode, "EUR")
    XCTAssertEqual(euro.numericCode, 978)
    XCTAssertEqual(euro.minorUnit, 2)
    XCTAssertEqual(euro.currencySymbol, "€")
    XCTAssertEqual(euro, Currency.EUR)
    XCTAssertEqual(Currency(alphabeticCode: "USD"), Currency.USD)
    XCTAssertEqual(Currency(alphabeticCode: "JPY"), Currency.JPY)
    XCTAssertNil(Currency(alphabeticCode: "ZZZ"))
    XCTAssertNil(Currency(alphabeticCode: ""))
    XCTAssertNil(Currency(alphabeticCode: "eur"))
    XCTAssertNil(Currency(alphabeticCode: "EURO"))
  }

  func testLookupByNumericCode() throws {
    XCTAssertEqual(Currency(numericCode: 978), Currency.EUR)
    XCTAssertEqual(Currency(numericCode: UInt16(840)), Currency.USD)
    XCTAssertEqual(Currency(numericCode: 756)?.alphabeticCode, "CHF")
    XCTAssertEqual(Currency(numericCode: 8)?.alphabeticCode, "ALL")
    XCTAssertNil(Currency(numericCode: 0))
    XCTAssertNil(Currency(numericCode: 1))
    XCTAssertNil(Currency(numericCode: UInt16.max))
    XCTAssertNil(Currency(numericCode: -1))
    XCTAssertNil(Currency(numericCode: 65536))
  }

  func testMinorUnits() throws {
    XCTAssertEqual(Currency.USD.minorUnit, 2)
    XCTAssertEqual(Currency.JPY.minorUnit, 0)
    XCTAssertEqual(Currency.BHD.minorUnit, 3)
    XCTAssertEqual(Currency.CLF.minorUnit, 4)
  }

  func testNamesAndDescription() throws {
    XCTAssertEqual(Currency.USD.name, "US Dollar")
    XCTAssertEqual(Currency.GBP.name, "Pound Sterling")
    XCTAssertEqual(Currency.JPY.name, "Yen")
    XCTAssertEqual(Currency.EUR.description, "EUR")
    XCTAssertEqual("\(Currency.CHF)", "CHF")
  }

  func testAvailableCurrencies() throws {
    let all = Currency.available
    XCTAssertGreaterThan(all.count, 150)
    XCTAssertEqual(Set(all.map(\.alphabeticCode)).count, all.count, "duplicate alphabetic codes")
    XCTAssertEqual(Set(all.map(\.numericCode)).count, all.count, "duplicate numeric codes")
    XCTAssertTrue(all.contains(Currency.EUR))
    XCTAssertTrue(all.contains(Currency.USD))
    for currency in all {
      XCTAssertEqual(currency.alphabeticCode.count, 3, currency.name)
      XCTAssertTrue(currency.alphabeticCode.allSatisfy { $0.isUppercase && $0.isASCII },
                    currency.alphabeticCode)
      XCTAssertLessThanOrEqual(currency.minorUnit, 4, currency.alphabeticCode)
      XCTAssertFalse(currency.name.isEmpty, currency.alphabeticCode)
      // Both lookups return the very same currency
      XCTAssertEqual(Currency(alphabeticCode: currency.alphabeticCode), currency)
      XCTAssertEqual(Currency(numericCode: currency.numericCode), currency)
    }
  }

  func testHashing() throws {
    XCTAssertEqual(Set([Currency.EUR, Currency.USD, Currency.EUR]).count, 2)
    XCTAssertEqual(Currency.EUR, Currency.EUR)
    XCTAssertNotEqual(Currency.EUR, Currency.USD)
    var table: [Currency: String] = [:]
    table[.EUR] = "euro"
    XCTAssertEqual(table[Currency(alphabeticCode: "EUR")!], "euro")
  }

  func testCodable() throws {
    let data = try JSONEncoder().encode(Currency.EUR)
    let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    XCTAssertEqual(json["alphabeticCode"] as? String, "EUR")
    XCTAssertEqual(json["numericCode"] as? Int, 978)
    XCTAssertEqual(json["name"] as? String, "Euro")
    XCTAssertEqual(json["minorUnit"] as? Int, 2)
    XCTAssertEqual(try JSONDecoder().decode(Currency.self, from: data), Currency.EUR)
    let all = try JSONEncoder().encode(Currency.available)
    XCTAssertEqual(try JSONDecoder().decode([Currency].self, from: all), Currency.available)
  }

  // MARK: - Currency symbols

  func testShortestSymbols() throws {
    XCTAssertEqual(Currency.USD.currencySymbol, "$")
    XCTAssertEqual(Currency.EUR.currencySymbol, "€")
    XCTAssertEqual(Currency.GBP.currencySymbol, "£")
    XCTAssertEqual(Currency.CHF.currencySymbol, "CHF")
    XCTAssertEqual(try XCTUnwrap(Currency.JPY.currencySymbol).count, 1)
  }

  func testSymbolsForLocales() throws {
    XCTAssertEqual(Currency.USD.currencySymbol(in: Locale(identifier: "en_US")), "$")
    XCTAssertEqual(Currency.USD.currencySymbol(in: Locale(identifier: "de_DE")), "$")
    XCTAssertEqual(Currency.EUR.currencySymbol(in: Locale(identifier: "de_DE")), "€")
    XCTAssertEqual(Currency.GBP.currencySymbol(in: Locale(identifier: "en_GB")), "£")
    XCTAssertEqual(Currency.CAD.currencySymbol(in: Locale(identifier: "en_CA")), "$")
    XCTAssertEqual(Currency.CAD.currencySymbol(in: Locale(identifier: "en_US")), "CA$")
    // Without a locale, a generic symbol is returned
    XCTAssertNotNil(Currency.EUR.currencySymbol(in: nil))
    XCTAssertNotNil(Currency.EUR.currencySymbol())
  }

  // MARK: - Directive ~$

  func testCurrencySymbolsInDirective() throws {
    XCTAssertEqual(try clformat("~,,,,978$", args: 1.5), "€1.50")
    XCTAssertEqual(try clformat("~,,,,840$", args: 1234.5), "$1234.50")
    XCTAssertEqual(try clformat("~,,,,826$", args: -7.5), "-£7.50")
    XCTAssertEqual(try clformat("~,,,,978@$", args: 1.5), "+€1.50")
    XCTAssertEqual(try clformat("~,2,12,,840$", args: 1234.5), "    $1234.50")
    XCTAssertEqual(normalized(try clformat("~,,,,756$", args: 2.25)), "CHF 2.25")
  }

  func testCurrencyCodesInDirective() throws {
    // A negative currency code selects the alphabetic code instead of the symbol
    XCTAssertEqual(normalized(try clformat("~,,,,-978$", args: 1.5)), "EUR 1.50")
    XCTAssertEqual(normalized(try clformat("~,,,,-840$", args: 1234.5)), "USD 1234.50")
    XCTAssertEqual(normalized(try clformat("~,,,,-756$", args: 2.25)), "CHF 2.25")
  }

  func testCurrencyCharacterInDirective() throws {
    XCTAssertEqual(try clformat("~,,,,'€$", args: 1.5), "€1.50")
    XCTAssertEqual(try clformat("~,,,,'#$", args: 1.5), "#1.50")
  }

  func testLocalizedCurrencySymbolsInDirective() throws {
    let german = Locale(identifier: "de_DE")
    XCTAssertEqual(normalized(try clformat("~,,,,978+$", locale: german, args: 1234.5)),
                   "1234,50 €")
    XCTAssertEqual(normalized(try clformat("~,,,,840+$", locale: german, args: 1234.5)),
                   "1234,50 $")
    XCTAssertEqual(try clformat("~,,,,978+$", locale: Locale(identifier: "en_US"), args: 1234.5),
                   "€1234.50")
    XCTAssertEqual(try clformat("~,,,,826+$", locale: Locale(identifier: "en_GB"), args: 1234.5),
                   "£1234.50")
    // Without the plus modifier, the locale is ignored
    XCTAssertEqual(try clformat("~,,,,978$", locale: german, args: 1234.5), "€1234.50")
  }

  func testUnknownCurrencyCodesInDirective() throws {
    XCTAssertEqual(try clformat("~,,,,70000$", args: 1.5), "1.50")
    XCTAssertEqual(try clformat("~,,,,-70000$", args: 1.5), "1.50")
    XCTAssertEqual(try clformat("~,,,,1$", args: 1.5), "1.50")
    XCTAssertEqual(try clformat("~,,,,-1$", args: 1.5), "1.50")
  }
}

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
  
  func testAscii() throws {
    XCTAssertEqual(try clformat("|~1,2,1A|", 7), "|7 |")
    XCTAssertEqual(try clformat("|~2,2,1A|", 7), "|7 |")
    XCTAssertEqual(try clformat("|~3,2,1A|", 7), "|7   |")
    XCTAssertEqual(try clformat("|~1,2,1@A|", 17), "| 17|")
    XCTAssertEqual(try clformat("|~2,2,1@A|", 17), "| 17|")
    XCTAssertEqual(try clformat("|~3,2,1@A|", 17), "| 17|")
    XCTAssertEqual(try clformat("|~4,2,1@A|", 17), "|   17|")
    XCTAssertEqual(try clformat("~33,,,'0A", 27), "270000000000000000000000000000000")
  }
  
  func testSexpr() throws {
    XCTAssertEqual(try clformat("|~S|", 12345678.1234), "|12345678.1234|")
    XCTAssertEqual(try clformat("|~S|", 9876512345678901234.1234), "|9.876512345678901e+18|")
    XCTAssertEqual(try clformat("|~S|", 12345678901234567.1234), "|1.2345678901234568e+16|")
    XCTAssertEqual(try clformat("|~S|", 1234567890123456789.1234), "|1.2345678901234568e+18|")
  }
  
  func testCharacters() throws {
    XCTAssertEqual(try clformat("~C", "Ü"), "Ü")
    XCTAssertEqual(try clformat("~@C vs. ~@C", "Ü", "A"),
                   "\"\\N{LATIN CAPITAL LETTER U WITH DIAERESIS}\" vs. \"A\"")
    XCTAssertEqual(try clformat("~:@C vs. ~:@C", "Ü", "A"), "\"\\u00DC\" vs. \"\\u0041\"")
    XCTAssertEqual(try clformat("~:C", "Ü"), "LATIN CAPITAL LETTER U WITH DIAERESIS")
    XCTAssertEqual(try clformat("~+C", "Ü"), "&#xDC;")
    XCTAssertEqual(try clformat("~:+C", "Ü"), "U+00DC")
  }
  
  func testDecimal() throws {
    XCTAssertEqual(try clformat("~? ~D", "<~A ~D>", ["Foo", 5], 7), "<Foo 5> 7")
    XCTAssertEqual(try clformat("~? ~D", "<~A ~D>", ["Foo", 5, 14], 7), "<Foo 5> 7")
    XCTAssertEqual(try clformat("~@? ~D", "<~A ~D>", "Foo", 5, 7), "<Foo 5> 7")
    XCTAssertEqual(try clformat("~@? ~D", "<~A ~D>", "Foo", 5, 14, 7), "<Foo 5> 14")
  }
  
  func testFixedFloat() throws {
    XCTAssertEqual(try clformat("|~F|", 123456.78901), "|123456.78901|")
    XCTAssertEqual(try clformat("|~,2F|", 123456.78901), "|123456.79|")
    XCTAssertEqual(try clformat("|~15F|", 123456.78901), "|   123456.78901|")
    XCTAssertEqual(try clformat("|~15,2F|", 123456.78901), "|      123456.79|")
    XCTAssertEqual(try clformat("|~15,2@F|", 123456.78901), "|     +123456.79|")
    XCTAssertEqual(try clformat("|~15,2,,,'_@F|", 0.011), "|__________+0.01|")
    XCTAssertEqual(try clformat("|~8,3F|", 123456.78901), "|123456.789|")
    XCTAssertEqual(try clformat("|~8,3,0,'-F|", 123456.78901), "|--------|")
    XCTAssertEqual(try clformat("|~8,3,-2F|", 123456.78901), "|1234.568|")
    XCTAssertEqual(try clformat("Float = <~14,5@F>", 12345.6789), "Float = <  +12345.67890>")
  }
  
  func testExpoFloat() throws {
    XCTAssertEqual(try clformat("|~E|", 1234567890123456789.1234), "|1.23456789012346E+18|")
    XCTAssertEqual(try clformat("|~9,2,1,,'*E|~10,3,2,2,'?,,'$E|~10,3,2,-2,'%@E|~9,2E|",
                                3.14159, 3.14159, 3.14159, 3.14159),
                "|  3.14E+0| 31.42$-01|+0.003E+03|  3.14E+0|")
    XCTAssertEqual(try clformat("|~9,2,1,,'*E|~10,3,2,2,'?,,'$E|~10,3,2,-2,'%@E|~9,2E|",
                                -3.14159, -3.14159, -3.14159, -3.14159),
                "| -3.14E+0|-31.42$-01|-0.003E+03| -3.14E+0|")
    XCTAssertEqual(try clformat("|~15,4,3,-3,'%,' ,'e@E|", 3.14159), "|   +0.0003e+004|")
    XCTAssertEqual(try clformat("|~15,4,3,-2,'%,' ,'e@E|", 3.14159), "|   +0.0031e+003|")
    XCTAssertEqual(try clformat("|~15,4,3,-1,'%,' ,'e@E|", 3.14159), "|   +0.0314e+002|")
    XCTAssertEqual(try clformat("|~15,4,3,0,'%,' ,'e@E|", 3.14159), "|   +0.3142e+001|")
    XCTAssertEqual(try clformat("|~15,4,3,1,'%,' ,'e@E|", 3.14159), "|   +3.1416e+000|")
    XCTAssertEqual(try clformat("|~15,4,3,2,'%,' ,'e@E|", 3.14159), "|   +31.416e-001|")
    XCTAssertEqual(try clformat("|~15,4,3,3,'%,' ,'e@E|", 3.14159), "|   +314.16e-002|")
    XCTAssertEqual(try clformat("|~,4,3,-3,'%,' ,'e@E|", 3.14159), "|+0.0003e+004|")
    XCTAssertEqual(try clformat("|~,4,3,-2,'%,' ,'e@E|", 3.14159), "|+0.0031e+003|")
    XCTAssertEqual(try clformat("|~,4,3,-1,'%,' ,'e@E|", 3.14159), "|+0.0314e+002|")
    XCTAssertEqual(try clformat("|~,4,3,0,'%,' ,'e@E|", 3.14159), "|+0.3142e+001|")
    XCTAssertEqual(try clformat("|~,4,3,1,'%,' ,'e@E|", 3.14159), "|+3.1416e+000|")
    XCTAssertEqual(try clformat("|~,4,3,2,'%,' ,'e@E|", 3.14159), "|+31.416e-001|")
    XCTAssertEqual(try clformat("|~,4,3,3,'%,' ,'e@E|", 3.14159), "|+314.16e-002|")
    XCTAssertEqual(try clformat("|~,,3,-3,'%,' ,'e@E|", 3.14159), "|+0.000314159e+004|")
    XCTAssertEqual(try clformat("|~,,3,-2,'%,' ,'e@E|", 3.14159), "|+0.00314159e+003|")
    XCTAssertEqual(try clformat("|~,,3,-1,'%,' ,'e@E|", 3.14159), "|+0.0314159e+002|")
    XCTAssertEqual(try clformat("|~,,3,0,'%,' ,'e@E|", 3.14159), "|+0.314159e+001|")
    XCTAssertEqual(try clformat("|~,,3,1,'%,' ,'e@E|", 3.14159), "|+3.14159e+000|")
    XCTAssertEqual(try clformat("|~,,3,2,'%,' ,'e@E|", 3.14159), "|+31.4159e-001|")
    XCTAssertEqual(try clformat("|~,,3,3,'%,' ,'e@E|", 3.14159), "|+314.159e-002|")
  }
  
  func testMonetaryFloat() throws {
    XCTAssertEqual(try clformat("|~$|~$|~$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "|7.99|2199.50|1234567.01|")
    XCTAssertEqual(try clformat("|~,3$|~,3$|~,3$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "|007.99|2199.50|1234567.01|")
    XCTAssertEqual(try clformat("|~,3,8$|~,3,8$|~,3,8$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "|  007.99| 2199.50|1234567.01|")
    XCTAssertEqual(try clformat("|~,3,8@$|~,3,8@$|~,3,8@$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "| +007.99|+2199.50|+1234567.01|")
    XCTAssertEqual(try clformat("|~,3,8:$|~,3,8:$|~,3,8:$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "|  007.99| 2199.50|1234567.01|")
    XCTAssertEqual(try clformat("|~,3,8:@$|~,3,8:@$|~,3,8:@$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "|+ 007.99|+2199.50|+1234567.01|")
    XCTAssertEqual(try clformat("|~,7,10$|~,7,10$|~,7,10$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "|0000007.99|0002199.50|1234567.01|")
    XCTAssertEqual(try clformat("|~,7,10@$|~,7,10@$|~,7,10@$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "|+0000007.99|+0002199.50|+1234567.01|")
    XCTAssertEqual(try clformat("|~,7,10:$|~,7,10:$|~,7,10:$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "|0000007.99|0002199.50|1234567.01|")
    XCTAssertEqual(try clformat("|~,7,10:@$|~,7,10:@$|~,7,10:@$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "|+0000007.99|+0002199.50|+1234567.01|")
    XCTAssertEqual(try clformat("|~,6,10$|~,6,10$|~,6,10$|", locale: Locale(identifier: "en_US"),
                                -7.99, -2199.5, -1234567.01),
                   "|-000007.99|-002199.50|-1234567.01|")
    XCTAssertEqual(try clformat("|~,6,10@$|~,6,10@$|~,6,10@$|", locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, -1234567.01),
                   "|+000007.99|+002199.50|-1234567.01|")
    XCTAssertEqual(try clformat("|~,6,10:$|~,6,10:$|~,6,10:$|", locale: Locale(identifier: "en_US"),
                                -7.99, -2199.5, -1234567.01),
                   "|-000007.99|-002199.50|-1234567.01|")
    XCTAssertEqual(try clformat("|~,6,10:@$|~,6,10:@$|~,6,10:@$|",
                                locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, -1234567.01),
                   "|+000007.99|+002199.50|-1234567.01|")
    XCTAssertEqual(try clformat("|~,,10,,'$,,$|~,5,10,,'€,,3$|~,2,10,,'£,,$|",
                                locale: Locale(identifier: "en_US"),
                                7.99, 2199.5, 1234567.01),
                   "|     $7.99|€02,199.50|£1234567.01|")
  }
  
  func testGeneralFloat() throws {
    XCTAssertEqual(try clformat("|~G|", 12.345), "|12.345    |")
    XCTAssertEqual(try clformat("|~G|", 1234.5678), "|1234.5678    |")
    XCTAssertEqual(try clformat("|~G|", 12345678.1234), "|12345678.1234    |")
    XCTAssertEqual(try clformat("|~9G|", 1234.5678), "|1234.5678    |")
    XCTAssertEqual(try clformat("|~10,4G|", 1234.5678), "|  1235    |")
    XCTAssertEqual(try clformat("|~15,4G|", 1234.5678), "|       1235    |")
    XCTAssertEqual(try clformat("|~15,4G|", 123456789.1234), "|      1.2346E+8|")
    XCTAssertEqual(try clformat("|~9,4G|", 123456789.1234), "|1.2346E+8|")
    XCTAssertEqual(try clformat("|~15,4G|", 1234567.1234), "|      1.2346E+6|")
    XCTAssertEqual(try clformat("|~15,5G|", 1234.1234), "|     1234.1    |")
    XCTAssertEqual(try clformat("|~15,2G|", 1234.1234), "|        1.23E+3|")
  }
  
  func testNumbers() throws {
    XCTAssertEqual(try clformat("Num: ~R", 17433),
                   "Num: seventeen thousand four hundred thirty-three")
    XCTAssertEqual(try clformat("Num: ~:R", 17433), "Num: 17'433rd")
    XCTAssertEqual(try clformat("Number ~D~:* as a roman numeral: ~@R", 1234),
                   "Number 1234 as a roman numeral: MCCXXXIV")
    XCTAssertEqual(try clformat("Num: ~:B", 1234), "Num: 100 1101 0010")
    XCTAssertEqual(try clformat("Num: ~O", 1234), "Num: 2322")
    XCTAssertEqual(try clformat("Num: ~X", 700000255), "Num: 29b927ff")
    XCTAssertEqual(try clformat("Num: ~+X", 700000255), "Num: 29B927FF")
    XCTAssertEqual(try clformat("~,,' ,4B", 0xFACE), "1111101011001110")
    XCTAssertEqual(try clformat("~,,' ,4:B", 0xFACE), "1111 1010 1100 1110")
    XCTAssertEqual(try clformat("~19,'0,' ,4B", 0x1CE), "0000000000111001110")
    XCTAssertEqual(try clformat("~19,'0,' ,4:B", 0x1CE), "000000001 1100 1110")
  }
  
  func testPlural() throws {
    XCTAssertEqual(try clformat("~D tr~:@P/~D win~:P", 7, 1), "7 tries/1 win")
    XCTAssertEqual(try clformat("~D tr~:@P/~D win~:P", 1, 0), "1 try/0 wins")
    XCTAssertEqual(try clformat("~D tr~:@P/~D win~:P", 1, 3), "1 try/3 wins")
  }
  
  func testTabulation() throws {
    XCTAssertEqual(try clformat("~5,4T"), "     ")
    XCTAssertEqual(try clformat(" ~5,4T"), "     ")
    XCTAssertEqual(try clformat("  ~5,4T"), "     ")
    XCTAssertEqual(try clformat("   ~5,4T"), "     ")
    XCTAssertEqual(try clformat("    ~5,4T"), "     ")
    XCTAssertEqual(try clformat("     ~5,4T"), "         ")
    XCTAssertEqual(try clformat("      ~5,4T"), "         ")
    XCTAssertEqual(try clformat("       ~5,4T"), "         ")
    XCTAssertEqual(try clformat("        ~5,4T"), "         ")
    XCTAssertEqual(try clformat("         ~5,4T"), "             ")
    XCTAssertEqual(try clformat("          ~5,4T"), "             ")
    XCTAssertEqual(try clformat("| ~5,4T"), "|    ")
    XCTAssertEqual(try clformat("|  ~5,4T"), "|    ")
    XCTAssertEqual(try clformat("|   ~5,4T"), "|    ")
    XCTAssertEqual(try clformat("|    ~5,4T"), "|        ")
    XCTAssertEqual(try clformat("|     ~5,4T"), "|        ")
    XCTAssertEqual(try clformat("|~5,4@T"), "|       ")
    XCTAssertEqual(try clformat("| ~5,4@T"), "|       ")
    XCTAssertEqual(try clformat("|  ~5,4@T"), "|       ")
    XCTAssertEqual(try clformat("|   ~5,4@T"), "|           ")
    XCTAssertEqual(try clformat("|    ~5,4@T"), "|           ")
    XCTAssertEqual(try clformat("|~5,0@T"), "|     ")
    XCTAssertEqual(try clformat("| ~5,0@T"), "|      ")
    XCTAssertEqual(try clformat("|  ~5,0@T"), "|       ")
    XCTAssertEqual(try clformat("|   ~5,0@T"), "|        ")
    XCTAssertEqual(try clformat("|    ~5,0@T"), "|         ")
    XCTAssertEqual(try clformat("|     ~5,0@T"), "|          ")
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
    XCTAssertEqual(try clformat("|~19:@<one~;two~^ four~;three~>|"), "|        one        |")
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
  
  func testAdvancedUseCases() throws {
    let choiceHash = "Items:~#[ none~; ~A~; ~A and ~A~:;~@{~#[~; and~] ~A~^,~}~]."
    XCTAssertEqual(try clformat(choiceHash), "Items: none.")
    XCTAssertEqual(try clformat(choiceHash, "FOO"), "Items: FOO.")
    XCTAssertEqual(try clformat(choiceHash, "FOO", "BAR"), "Items: FOO and BAR.")
    XCTAssertEqual(try clformat(choiceHash, "FOO", "BAR", "BAZ"), "Items: FOO, BAR, and BAZ.")
    XCTAssertEqual(try clformat(choiceHash, "FOO", "BAR", "BAZ", "GOO"), "Items: FOO, BAR, BAZ, and GOO.")
    XCTAssertEqual(try clformat("Pairs:~:@{ <~A,~A>~}.", ["A", 1], ["B", 2], ["C", 3]), "Pairs: <A,1> <B,2> <C,3>.")
    XCTAssertEqual(try clformat("~A and ~A and ~A", 1, nil, 3), "1 and nil and 3")
    XCTAssertEqual(try clformat("~:{/~A~^ ...~}", [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]]), "/hot .../hamburger/ice .../french ...")
    XCTAssertEqual(try clformat("~:{/~A~:^ ...~}", [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]]), "/hot .../hamburger .../ice .../french")
    XCTAssertEqual(try clformat("~:{/~A~#:^ ...~}", [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]]), "/hot .../hamburger")
    XCTAssertEqual(try clformat("hello~%~10~~%~2&~:@(world~). Number ~#[Zero~;One~;Two~:;Three~]." +
                                " This is ~:[False~;True~]. ~@[My name is ~A. ~]! ~3{~A ~}",
                                2, "unknown", [1, "two", 3, 4]),
                   """
                   hello
                   ~~~~~~~~~~

                   WORLD. Number Three. This is True. My name is unknown. ! 1 two 3 
                   """)
    XCTAssertEqual(try clformat("Num1: ~,,' :+D, Num2: ~12@D, Num3: ~10,'_,',,4:D, " +
                                "Num4: ~2,64,'.,' ,4:R",
                                1735.45, 98346283, -123245, 655310899),
                   "Num1: 1 735.45, Num2:    +98346283, Num3: __-12,3245, " +
                   "Num4: ...........................10 0111 0000 1111 0100 0000 0011 0011")
  }
  
  func testUpAndOutJustification() throws {
    XCTAssertEqual(try clformat("~%;;~{~<~%;;~1,50:; ~A~>~^,~}.~%",
                                ["one dfdafadf", "two adfadfadf", "three adfdaf adffda",
                                       "four adf adfadf adfadf adfaffaf"]),
                   """
                   
                   ;; one dfdafadf, two adfadfadf,
                   ;; three adfdaf adffda,
                   ;; four adf adfadf adfadf adfaffaf.
                   
                   """)
  }
  
  func testExtensions() throws {
    XCTAssertEqual(try clformat("~e and ~,4e", Double.pi, Double.pi),
                   "3.14159265358979E+0 and 3.1416E+0")
    XCTAssertEqual(try clformat("~$ and ~2,4$", Double.pi, Double.pi),
                   "3.14 and 0003.14")
    XCTAssertEqual(try clformat("|~10,,,,10@A|", "One two"), "|   One two|")
    XCTAssertEqual(try clformat("|~10,,,,10@A|", "One two three"), "|One two t…|")
    XCTAssertEqual(try clformat("|one~\n  two~\n three~\nfour|"), "|onetwothreefour|")
    XCTAssertEqual(try clformat("|one~:\n  two~@\n   ~Athree~:\nfour|", 101),
                   "|one  two\n101threefour|")
  }
}

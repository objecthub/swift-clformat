//
//  main.swift
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

func assertEqual(_ str: String, _ target: String) {
  if str == target {
    print("[PASS] \"\(str)\"")
  } else {
    print("[FAIL] \"\(str)\" vs. \"\(target)\"")
  }
}

let choiceHash = "Items:~#[ none~; ~A~; ~A and ~A~:;~@{~#[~; and~] ~A~^,~}~]."
assertEqual(try clformat(choiceHash), "Items: none.")
assertEqual(try clformat(choiceHash, args: "FOO"), "Items: FOO.")
assertEqual(try clformat(choiceHash, args: "FOO", "BAR"), "Items: FOO and BAR.")
assertEqual(try clformat(choiceHash, args: "FOO", "BAR", "BAZ"), "Items: FOO, BAR, and BAZ.")
assertEqual(try clformat(choiceHash, args: "FOO", "BAR", "BAZ", "GOO"), "Items: FOO, BAR, BAZ, and GOO.")
assertEqual(try clformat("Pairs:~:@{ <~A,~A>~}.", args: ["A", 1], ["B", 2], ["C", 3]), "Pairs: <A,1> <B,2> <C,3>.")
assertEqual(try clformat("~A and ~A and ~A", args: 1, nil, 3), "1 and nil and 3")
assertEqual(try clformat("~:{/~A~^ ...~}", args: [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]]), "/hot .../hamburger/ice .../french ...")
assertEqual(try clformat("~:{/~A~:^ ...~}", args: [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]]), "/hot .../hamburger .../ice .../french")
assertEqual(try clformat("~:{/~A~#:^ ...~}", args: [["hot", "dog"], ["hamburger"], ["ice", "cream"], ["french", "fries"]]), "/hot .../hamburger")
assertEqual(try clformat("~D tr~:@P/~D win~:P", args: 7, 1), "7 tries/1 win")
assertEqual(try clformat("~D tr~:@P/~D win~:P", args: 1, 0), "1 try/0 wins")
assertEqual(try clformat("~D tr~:@P/~D win~:P", args: 1, 3), "1 try/3 wins")
assertEqual(try clformat("~C", args: "Ü"), "Ü")
assertEqual(try clformat("~@C vs. ~@C", args: "Ü", "A"), "\"\\N{LATIN CAPITAL LETTER U WITH DIAERESIS}\" vs. \"A\"")
assertEqual(try clformat("~:@C vs. ~:@C", args: "Ü", "A"), "\"\\u00DC\" vs. \"\\u0041\"")
assertEqual(try clformat("~:C", args: "Ü"), "LATIN CAPITAL LETTER U WITH DIAERESIS")
assertEqual(try clformat("~+C", args: "Ü"), "&#xDC;")
assertEqual(try clformat("~:+C", args: "Ü"), "U+00DC")
assertEqual(try clformat("|~F|", args: 123456.78901), "|123456.78901|")
assertEqual(try clformat("|~,2F|", args: 123456.78901), "|123456.79|")
assertEqual(try clformat("|~15F|", args: 123456.78901), "|   123456.78901|")
assertEqual(try clformat("|~15,2F|", args: 123456.78901), "|      123456.79|")
assertEqual(try clformat("|~15,2@F|", args: 123456.78901), "|     +123456.79|")
assertEqual(try clformat("|~15,2,,,'_@F|", args: 0.011), "|__________+0.01|")
assertEqual(try clformat("|~8,3F|", args: 123456.78901), "|123456.789|")
assertEqual(try clformat("|~8,3,0,'-F|", args: 123456.78901), "|--------|")
assertEqual(try clformat("|~8,3,-2F|", args: 123456.78901), "|1234.568|")
assertEqual(try clformat("|~9,2,1,,'*E|~10,3,2,2,'?,,'$E|~10,3,2,-2,'%@E|~9,2E|", args: 3.14159, 3.14159, 3.14159, 3.14159),
            "|  3.14E+0| 31.42$-01|+0.003E+03|  3.14E+0|")
assertEqual(try clformat("|~9,2,1,,'*E|~10,3,2,2,'?,,'$E|~10,3,2,-2,'%@E|~9,2E|", args: -3.14159, -3.14159, -3.14159, -3.14159),
            "| -3.14E+0|-31.42$-01|-0.003E+03| -3.14E+0|")
assertEqual(try clformat("|~15,4,3,-3,'%,' ,'e@E|", args: 3.14159), "|   +0.0003e+004|")
assertEqual(try clformat("|~15,4,3,-2,'%,' ,'e@E|", args: 3.14159), "|   +0.0031e+003|")
assertEqual(try clformat("|~15,4,3,-1,'%,' ,'e@E|", args: 3.14159), "|   +0.0314e+002|")
assertEqual(try clformat("|~15,4,3,0,'%,' ,'e@E|", args: 3.14159), "|   +0.3142e+001|")
assertEqual(try clformat("|~15,4,3,1,'%,' ,'e@E|", args: 3.14159), "|   +3.1416e+000|")
assertEqual(try clformat("|~15,4,3,2,'%,' ,'e@E|", args: 3.14159), "|   +31.416e-001|")
assertEqual(try clformat("|~15,4,3,3,'%,' ,'e@E|", args: 3.14159), "|   +314.16e-002|")
assertEqual(try clformat("|~,4,3,-3,'%,' ,'e@E|", args: 3.14159), "|+0.0003e+004|")
assertEqual(try clformat("|~,4,3,-2,'%,' ,'e@E|", args: 3.14159), "|+0.0031e+003|")
assertEqual(try clformat("|~,4,3,-1,'%,' ,'e@E|", args: 3.14159), "|+0.0314e+002|")
assertEqual(try clformat("|~,4,3,0,'%,' ,'e@E|", args: 3.14159), "|+0.3142e+001|")
assertEqual(try clformat("|~,4,3,1,'%,' ,'e@E|", args: 3.14159), "|+3.1416e+000|")
assertEqual(try clformat("|~,4,3,2,'%,' ,'e@E|", args: 3.14159), "|+31.416e-001|")
assertEqual(try clformat("|~,4,3,3,'%,' ,'e@E|", args: 3.14159), "|+314.16e-002|")
assertEqual(try clformat("|~,,3,-3,'%,' ,'e@E|", args: 3.14159), "|+0.000314159e+004|")
assertEqual(try clformat("|~,,3,-2,'%,' ,'e@E|", args: 3.14159), "|+0.00314159e+003|")
assertEqual(try clformat("|~,,3,-1,'%,' ,'e@E|", args: 3.14159), "|+0.0314159e+002|")
assertEqual(try clformat("|~,,3,0,'%,' ,'e@E|", args: 3.14159), "|+0.314159e+001|")
assertEqual(try clformat("|~,,3,1,'%,' ,'e@E|", args: 3.14159), "|+3.14159e+000|")
assertEqual(try clformat("|~,,3,2,'%,' ,'e@E|", args: 3.14159), "|+31.4159e-001|")
assertEqual(try clformat("|~,,3,3,'%,' ,'e@E|", args: 3.14159), "|+314.159e-002|")
assertEqual(try clformat("~5,4T"), "     ")
assertEqual(try clformat(" ~5,4T"), "     ")
assertEqual(try clformat("  ~5,4T"), "     ")
assertEqual(try clformat("   ~5,4T"), "     ")
assertEqual(try clformat("    ~5,4T"), "     ")
assertEqual(try clformat("     ~5,4T"), "         ")
assertEqual(try clformat("      ~5,4T"), "         ")
assertEqual(try clformat("       ~5,4T"), "         ")
assertEqual(try clformat("        ~5,4T"), "         ")
assertEqual(try clformat("         ~5,4T"), "             ")
assertEqual(try clformat("          ~5,4T"), "             ")
assertEqual(try clformat("| ~5,4T"), "|    ")
assertEqual(try clformat("|  ~5,4T"), "|    ")
assertEqual(try clformat("|   ~5,4T"), "|    ")
assertEqual(try clformat("|    ~5,4T"), "|        ")
assertEqual(try clformat("|     ~5,4T"), "|        ")
assertEqual(try clformat("|~5,4@T"), "|       ")
assertEqual(try clformat("| ~5,4@T"), "|       ")
assertEqual(try clformat("|  ~5,4@T"), "|       ")
assertEqual(try clformat("|   ~5,4@T"), "|           ")
assertEqual(try clformat("|    ~5,4@T"), "|           ")
assertEqual(try clformat("|~5,0@T"), "|     ")
assertEqual(try clformat("| ~5,0@T"), "|      ")
assertEqual(try clformat("|  ~5,0@T"), "|       ")
assertEqual(try clformat("|   ~5,0@T"), "|        ")
assertEqual(try clformat("|    ~5,0@T"), "|         ")
assertEqual(try clformat("|     ~5,0@T"), "|          ")
assertEqual(try clformat("~33,,,'0A", args: 27), "270000000000000000000000000000000")
assertEqual(try clformat("|~S|", args: 12345678.1234), "|1.2345678e7|")
assertEqual(try clformat("|~S|", args: 12345678901234567.1234), "|1.2345678901234568e+16|")
assertEqual(try clformat("|~S|", args: 1234567890123456789.1234), "|1.2345678901234568e+18|")
assertEqual(try clformat("|~E|", args: 1234567890123456789.1234), "|1.23456789012346E+18|")
assertEqual(try clformat("|~G|", args: 12.345), "|12.345    |")
assertEqual(try clformat("|~G|", args: 1234.5678), "|1234.5678    |")
assertEqual(try clformat("|~G|", args: 12345678.1234), "|12345678.    |")
assertEqual(try clformat("|~9G|", args: 1234.5678), "|1234.5678    |")
assertEqual(try clformat("|~10,4G|", args: 1234.5678), "|  1235    |")
assertEqual(try clformat("|~15,4G|", args: 1234.5678), "|       1235    |")
assertEqual(try clformat("|~15,4G|", args: 123456789.1234), "|      1.2346E+8|")
assertEqual(try clformat("|~9,4G|", args: 123456789.1234), "|1.2346E+8|")
assertEqual(try clformat("|~15,4G|", args: 1234567.1234), "|      1.2346E+6|")
assertEqual(try clformat("|~15,5G|", args: 1234.1234), "|     1234.1    |")
assertEqual(try clformat("|~15,2G|", args: 1234.1234), "|        1.23E+3|")
assertEqual(try clformat("|~1,2,1A|", args: 7), "|7 |")
assertEqual(try clformat("|~2,2,1A|", args: 7), "|7 |")
assertEqual(try clformat("|~3,2,1A|", args: 7), "|7   |")
assertEqual(try clformat("|~1,2,1@A|", args: 17), "| 17|")
assertEqual(try clformat("|~2,2,1@A|", args: 17), "| 17|")
assertEqual(try clformat("|~3,2,1@A|", args: 17), "| 17|")
assertEqual(try clformat("|~4,2,1@A|", args: 17), "|   17|")
assertEqual(try clformat("|~$|~$|~$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "|7.99|2199.50|1234567.01|")
assertEqual(try clformat("|~,3$|~,3$|~,3$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "|007.99|2199.50|1234567.01|")
assertEqual(try clformat("|~,3,8$|~,3,8$|~,3,8$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "|  007.99| 2199.50|1234567.01|")
assertEqual(try clformat("|~,3,8@$|~,3,8@$|~,3,8@$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "| +007.99|+2199.50|+1234567.01|")
assertEqual(try clformat("|~,3,8:$|~,3,8:$|~,3,8:$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "|  007.99| 2199.50|1234567.01|")
assertEqual(try clformat("|~,3,8:@$|~,3,8:@$|~,3,8:@$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "|+ 007.99|+2199.50|+1234567.01|")
assertEqual(try clformat("|~,7,10$|~,7,10$|~,7,10$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "|0000007.99|0002199.50|1234567.01|")
assertEqual(try clformat("|~,7,10@$|~,7,10@$|~,7,10@$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "|+0000007.99|+0002199.50|+1234567.01|")
assertEqual(try clformat("|~,7,10:$|~,7,10:$|~,7,10:$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "|0000007.99|0002199.50|1234567.01|")
assertEqual(try clformat("|~,7,10:@$|~,7,10:@$|~,7,10:@$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "|+0000007.99|+0002199.50|+1234567.01|")
assertEqual(try clformat("|~,6,10$|~,6,10$|~,6,10$|", locale: Locale(identifier: "en_US"), args: -7.99, -2199.5, -1234567.01), "|-000007.99|-002199.50|-1234567.01|")
assertEqual(try clformat("|~,6,10@$|~,6,10@$|~,6,10@$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, -1234567.01), "|+000007.99|+002199.50|-1234567.01|")
assertEqual(try clformat("|~,6,10:$|~,6,10:$|~,6,10:$|", locale: Locale(identifier: "en_US"), args: -7.99, -2199.5, -1234567.01), "|-000007.99|-002199.50|-1234567.01|")
assertEqual(try clformat("|~,6,10:@$|~,6,10:@$|~,6,10:@$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, -1234567.01), "|+000007.99|+002199.50|-1234567.01|")
assertEqual(try clformat("|~,,10,,'$,,$|~,5,10,,'€,,3$|~,2,10,,'£,,$|", locale: Locale(identifier: "en_US"), args: 7.99, 2199.5, 1234567.01), "|0000007.99|0002199.50|1234567.01|")

assertEqual(try clformat("~? ~D", args: "<~A ~D>", ["Foo", 5], 7), "<Foo 5> 7")
assertEqual(try clformat("~? ~D", args: "<~A ~D>", ["Foo", 5, 14], 7), "<Foo 5> 7")
assertEqual(try clformat("~@? ~D", args: "<~A ~D>", "Foo", 5, 7), "<Foo 5> 7")
assertEqual(try clformat("~@? ~D", args: "<~A ~D>", "Foo", 5, 14, 7), "<Foo 5> 14")

// assertEqual(try clformat("~9,2,1,,'*G|~9,3,2,3,' ?,,'$G|~9,3,2,0,'%G|~9,2G", args: 0.0314159, 0.0314159, 0.0314159), "|          ")

print(try clformat("hello~%~10~~%~2&~:@(world~). Number ~#[Zero~;One~;Two~:;Three~]. This is ~:[False~;True~]. ~@[My name is ~A. ~]Ok? ~3{~A ~}", args: 2, "Matthias", [1, "two", 3, 4]))

print(try clformat("Num1: ~,,' :+D, Num2: ~12@D, Num3: ~10,'_,',,4:D, Num4: ~2,64,'.,' ,4:R", args: 1735.45, 98346283, -123245, 655310899))

print(try clformat("Num1: ~R", args: 17433))
print(try clformat("Num1: ~:R", args: 17433))
print(try clformat("Number ~D~:* as a roman numeral: ~@R", args: 1234))
print(try clformat("Num1: ~:B", args: 1234))
print(try clformat("Num1: ~O", args: 1234))
print(try clformat("Num1: ~X", args: 700000255))

print(try clformat("Float = ~14,5@F", args: 12345.6789))

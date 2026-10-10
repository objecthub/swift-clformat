//
//  CLFormatAPITests.swift
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

// MARK: - Test support

/// A type with custom formatting for `~A` and `~:A`.
private struct Point: CLFormatConvertible, DebugCLFormatConvertible {
  let x: Int
  let y: Int
  var clformatDescription: String {
    return "(\(self.x), \(self.y))"
  }
  var clformatDebugDescription: String {
    return "Point(x: \(self.x), y: \(self.y))"
  }
}

/// A directive that reverses the next argument, which is expected to be a string.
private struct ReverseSpecifier: DirectiveSpecifier {
  var identifier: Character {
    return "Z"
  }
  var description: String {
    return "Z"
  }
  func apply(context: Context,
             parameters: Parameters,
             modifiers: Modifiers,
             arguments: Arguments) throws -> Instruction {
    return .append(String(try arguments.nextAsString().reversed()))
  }
}

/// A directive that outputs a value from the environment of the format configuration.
private struct EnvironmentSpecifier: DirectiveSpecifier {
  var identifier: Character {
    return "K"
  }
  var description: String {
    return "K"
  }
  func apply(context: Context,
             parameters: Parameters,
             modifiers: Modifiers,
             arguments: Arguments) throws -> Instruction {
    return .append("\(context.config.environment["prefix"] ?? "?")\(try arguments.next() ?? "")")
  }
}

/// Arguments for which the string "NIL" counts as `nil`.
private final class LispArguments: Arguments {
  override func isNil(_ obj: Any?) -> Bool {
    return super.isNil(obj) || (obj as? String) == "NIL"
  }
}

final class CLFormatAPITests: XCTestCase {

  /// Captures what `body` writes to the standard output.
  private func captureStandardOutput(_ body: () -> Void) -> String {
    let path = NSTemporaryDirectory() + "clformat-\(UUID().uuidString).txt"
    defer { try? FileManager.default.removeItem(atPath: path) }
    fflush(nil)
    let saved = dup(STDOUT_FILENO)
    let file = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0o600)
    dup2(file, STDOUT_FILENO)
    close(file)
    defer {
      fflush(nil)
      dup2(saved, STDOUT_FILENO)
      close(saved)
    }
    body()
    fflush(nil)
    return (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
  }

  // MARK: - Entry points

  func testClformatVariants() throws {
    XCTAssertEqual(try clformat("~A and ~A", args: 1, "two"), "1 and two")
    XCTAssertEqual(try clformat("~A and ~A", arguments: [1, "two"]), "1 and two")
    XCTAssertEqual(try clformat("no directives"), "no directives")
    XCTAssertEqual(try clformat(""), "")
    XCTAssertEqual(try clformat("~~~%~~"), "~\n~")
    // Arguments that are not consumed are ignored
    XCTAssertEqual(try clformat("~A", args: 1, 2, 3), "1")
  }

  func testStringInitializers() throws {
    XCTAssertEqual(try String(control: "~D + ~D", args: 1, 2), "1 + 2")
    XCTAssertEqual(try String(control: "~D + ~D", arguments: [1, 2]), "1 + 2")
    XCTAssertEqual(try String(control: "~,2F", args: 3.14159), "3.14")
    XCTAssertEqual(try String(control: "~,2F", arguments: [3.14159]), "3.14")
    XCTAssertEqual(try String(control: "~,2+F", locale: Locale(identifier: "de_DE"),
                              args: 3.14159), "3,14")
    XCTAssertEqual(try String(control: "~,2+F", locale: Locale(identifier: "de_DE"),
                              arguments: [3.14159]), "3,14")
    XCTAssertEqual(try String(control: "|~16:@<✅1~>|", displayWidth: true, args: nil),
                   "|       ✅1      |")
    XCTAssertEqual(try String(control: "\t~12T", tabsize: 4, args: nil), "\t" + String(repeating: " ", count: 8))
    // Custom configurations are supported
    var config = CLFormatConfig.standard
    config.nilRepresentation = "none"
    XCTAssertEqual(try String(control: "~A", config: config, args: nil), "none")
    XCTAssertEqual(try String(control: "~A", config: config, arguments: [nil]), "none")
    XCTAssertThrowsError(try String(control: "~Q", args: 1))
    XCTAssertThrowsError(try String(control: "~Q", arguments: [1]))
  }

  func testLocaleParameter() throws {
    let german = Locale(identifier: "de_DE")
    XCTAssertEqual(try clformat("~,2+F", locale: german, args: 1234.5), "1234,50")
    XCTAssertEqual(try clformat("~,2:+F", locale: german, args: 1234.5), "1.234,50")
    XCTAssertEqual(try clformat("~:+D", locale: german, args: 1234567), "1.234.567")
    XCTAssertEqual(try clformat("~,2+F", locale: Locale(identifier: "en_US"), args: 1234.5),
                   "1234.50")
    // The locale only matters if the plus modifier is used
    XCTAssertEqual(try clformat("~,2:F", locale: german, args: 1234.5), "1,234.50")
    // (Spelled-out numbers may contain soft hyphens)
    XCTAssertEqual(try clformat("~+R", locale: german, args: 21)
                     .replacingOccurrences(of: "\u{ad}", with: ""), "einundzwanzig")
  }

  func testTabsizeParameter() throws {
    XCTAssertEqual(try clformat("\t~12T", tabsize: 4), "\t" + String(repeating: " ", count: 8))
    XCTAssertEqual(try clformat("\t~12T", tabsize: 8), "\t" + String(repeating: " ", count: 4))
    XCTAssertEqual(try clformat("ab\tc~12T", tabsize: 8), "ab\tc" + String(repeating: " ", count: 3))
  }

  func testLinewidthParameter() throws {
    let args = ["first line", "second", "a long third line", "fourth"]
    // Without an explicit line width in the directive, the parameter determines the lines
    let control = "~%;; ~{~<~%;; ~1:; ~S~>~^,~}.~%"
    let wide = try clformat(control, linewidth: 80, args: args)
    let narrow = try clformat(control, linewidth: 25, args: args)
    XCTAssertEqual(wide.split(separator: "\n").count, 1)
    XCTAssertGreaterThan(narrow.split(separator: "\n").count, 2)
    XCTAssertEqual(try clformat(control, args: args), wide, "the default line width is 80")
    // An explicit line width in the directive wins
    let explicit = "~{~<~%;; ~1,30:; ~S~>~^,~}"
    XCTAssertEqual(try clformat(explicit, linewidth: 20, args: args),
                   try clformat(explicit, linewidth: 80, args: args))
  }

  func testClprintf() throws {
    XCTAssertEqual(captureStandardOutput {
      try! clprintf("Hello ~A!", args: "world")
    }, "Hello world!\n")
    XCTAssertEqual(captureStandardOutput {
      try! clprintf("~D-~D", arguments: [1, 2])
    }, "1-2\n")
    XCTAssertEqual(captureStandardOutput {
      try! clprintf("no newline", args: nil, terminator: "")
    }, "no newline")
    XCTAssertEqual(captureStandardOutput {
      try! clprintf("~A", arguments: ["x"], terminator: "|")
    }, "x|")
    // Nothing is printed if formatting fails
    var failed = false
    XCTAssertEqual(captureStandardOutput {
      do {
        try clprintf("~Q", args: 1)
      } catch {
        failed = true
      }
    }, "")
    XCTAssertTrue(failed)
  }

  // MARK: - Convertible protocols

  func testConvertibleArguments() throws {
    let point = Point(x: 3, y: 4)
    XCTAssertEqual(try clformat("~A", args: point), "(3, 4)")
    XCTAssertEqual(try clformat("~:A", args: point), "Point(x: 3, y: 4)")
    XCTAssertEqual(try clformat("~S", args: point), "(3, 4)")
    XCTAssertEqual(try clformat("~:S", args: point), "Point(x: 3, y: 4)")
    XCTAssertEqual(try clformat("~A", args: [point, point]), "[(3, 4), (3, 4)]")
    XCTAssertEqual(try clformat("~:A", args: [point, point]),
                   "[Point(x: 3, y: 4), Point(x: 3, y: 4)]")
    XCTAssertEqual(try clformat("~{~A~^;~}", args: [point, Point(x: 1, y: 2)]),
                   "(3, 4);(1, 2)")
    XCTAssertEqual(try clformat("|~12A|", args: point), "|(3, 4)      |")
    XCTAssertEqual(try clformat("|~12@A|", args: point), "|      (3, 4)|")
  }

  func testConvertibleCollections() throws {
    let points = [Point(x: 1, y: 2), Point(x: 3, y: 4)]
    XCTAssertEqual(points.clformatDescription, "[(1, 2), (3, 4)]")
    XCTAssertEqual(points.clformatDebugDescription, "[Point(x: 1, y: 2), Point(x: 3, y: 4)]")
    XCTAssertEqual([Point]().clformatDescription, "[]")
    XCTAssertEqual([Point(x: 5, y: 6)].clformatDescription, "[(5, 6)]")
    let none: Point? = nil
    XCTAssertEqual(none.clformatDescription, "nil")
    XCTAssertEqual(none.clformatDebugDescription, "nil")
    XCTAssertEqual(Optional(Point(x: 1, y: 2)).clformatDescription, "(1, 2)")
    XCTAssertEqual(Optional(Point(x: 1, y: 2)).clformatDebugDescription, "Point(x: 1, y: 2)")
    // Values that are not convertible fall back on their debug description
    XCTAssertEqual(Optional("text").clformatDescription, "\"text\"")
    XCTAssertEqual(Optional(5).clformatDescription, "5")
    XCTAssertEqual(Optional(5).clformatDebugDescription, "5")
    XCTAssertEqual(Optional(2.5).clformatDescription, "2.5")
  }

  // MARK: - Format configurations

  func testCustomDirectives() throws {
    var config = CLFormatConfig.standard
    XCTAssertNil(config.parser(for: "Z"))
    config.parse("Z", appending: ReverseSpecifier())
    XCTAssertNotNil(config.parser(for: "Z"))
    XCTAssertEqual(try clformat("~Z and ~A", config: config, args: "abc", "x"), "cba and x")
    XCTAssertEqual(try clformat("|~Z|", config: config, args: "hello"), "|olleh|")
    // Standard directives are still available
    XCTAssertEqual(try clformat("~D~Z", config: config, args: 5, "xy"), "5yx")
    // The default configuration is not affected
    XCTAssertThrowsError(try clformat("~Z", args: "abc"))
    XCTAssertThrowsError(try clformat("~Z", config: CLFormatConfig.standard, args: "abc"))
  }

  func testCustomDirectiveParsers() throws {
    var config = CLFormatConfig.standard
    // A parser can map a directive to any other directive specifier
    config.parse("y", "Y") { parser, parameters, modifiers in
      return .append(parameters, modifiers, StandardDirectiveSpecifier.decimal)
    }
    XCTAssertEqual(try clformat("~y|~Y", config: config, args: 1, 2), "1|2")
    // A parser can also drop directives
    config.parse("w") { parser, parameters, modifiers in
      return .ignore
    }
    XCTAssertEqual(try clformat("a~wb", config: config), "ab")
    // Parsers can be registered for lists of characters
    config.parse(["k", "l"]) { parser, parameters, modifiers in
      return .append(Directive(parameters: parameters,
                               modifiers: modifiers,
                               specifier: ReverseSpecifier()))
    }
    XCTAssertEqual(try clformat("~k~l", config: config, args: "ab", "cd"), "badc")
  }

  func testRemovingDirectives() throws {
    var config = CLFormatConfig.standard
    XCTAssertNotNil(config.parser(for: "A"))
    config.remove("A", "a")
    XCTAssertNil(config.parser(for: "A"))
    XCTAssertNil(config.parser(for: "a"))
    XCTAssertNotNil(config.parser(for: "D"))
    XCTAssertThrowsError(try clformat("~A", config: config, args: 1)) { error in
      XCTAssertEqual((error as? CLControlError)?.description, "unknown directive ~A")
    }
    XCTAssertEqual(try clformat("~D", config: config, args: 1), "1")
    // The standard configuration is a value
    XCTAssertNotNil(CLFormatConfig.standard.parser(for: "A"))
  }

  func testConfigurationEnvironment() throws {
    var config = CLFormatConfig.standard
    config.parse("K", appending: EnvironmentSpecifier())
    XCTAssertEqual(try clformat("~K", config: config, args: "x"), "?x")
    config.environment["prefix"] = ">> "
    XCTAssertEqual(try clformat("~K", config: config, args: "x"), ">> x")
    XCTAssertEqual(config.environment.count, 1)
  }

  func testNilRepresentation() throws {
    var config = CLFormatConfig.standard
    XCTAssertEqual(config.nilRepresentation, "nil")
    config.nilRepresentation = "<none>"
    XCTAssertEqual(try clformat("~A ~S ~W", config: config, arguments: [nil, nil, nil]),
                   "<none> <none> <none>")
    XCTAssertEqual(try clformat("~A ~S ~W", arguments: [nil, nil, nil]), "nil nil nil")
    XCTAssertEqual(CLFormatConfig(nilRepresentation: "NULL").nilRepresentation, "NULL")
    XCTAssertNil(CLFormatConfig().parser(for: "A"), "a fresh configuration has no directives")
  }

  func testCustomArgumentFactory() throws {
    var config = CLFormatConfig.standard
    config.setArgumentFactory { locale, tabsize, linewidth, displayWidth, args, left in
      return LispArguments(locale: locale,
                           tabsize: tabsize,
                           linewidth: linewidth,
                           displayWidth: displayWidth,
                           args: args,
                           numArgumentsLeft: left)
    }
    let control = "~:[empty~;full~]"
    XCTAssertEqual(try clformat(control, config: config, args: "NIL"), "empty")
    XCTAssertEqual(try clformat(control, config: config, args: nil), "empty")
    XCTAssertEqual(try clformat(control, config: config, args: "text"), "full")
    // Standard arguments do not know about "NIL"
    XCTAssertEqual(try clformat(control, args: "NIL"), "full")
    // Arguments are created via the configuration
    let args = config.makeArguments(locale: Locale(identifier: "fr_FR"),
                                    tabsize: 4,
                                    linewidth: 50,
                                    displayWidth: true,
                                    args: [1, 2, 3],
                                    numArgumentsLeft: nil)
    XCTAssertTrue(args is LispArguments)
    XCTAssertEqual(args.locale?.identifier, "fr_FR")
    XCTAssertEqual(args.tabsize, 4)
    XCTAssertEqual(args.linewidth, 50)
    XCTAssertTrue(args.displayWidth)
    XCTAssertEqual(args.count, 3)
    // Nested arguments keep the type of the arguments
    XCTAssertTrue(args.new(args: [1]) is LispArguments)
  }

  func testDirectiveParsersUsedByControls() throws {
    var config = CLFormatConfig.standard
    config.parse("Z", appending: ReverseSpecifier())
    let control = try CLControl(string: "a~Zb", config: config)
    XCTAssertEqual(control.components.count, 3)
    XCTAssertEqual(try control.format(args: "xyz"), "azyxb")
    XCTAssertNotNil(control.config.parser(for: "Z"), "controls keep their configuration")
    // Indirection uses the configuration of the control
    XCTAssertEqual(try clformat("~?", config: config, args: "<~Z>", ["abc"] as [Any?]), "<cba>")
  }

  // MARK: - Controls

  func testControlRepresentation() throws {
    let control = try CLControl(string: "Total: ~D item~:P")
    XCTAssertFalse(control.isEmpty)
    XCTAssertEqual(control.components.count, 4)
    XCTAssertEqual(control.description, "\"Total: \", ~D, \" item\", ~:P")
    XCTAssertTrue(try CLControl(string: "").isEmpty)
    XCTAssertEqual(try CLControl(string: "").description, "")
    XCTAssertEqual(try CLControl(string: "~(~A~)").description, "~(~A)")
  }

  func testControlComponents() throws {
    let control = try CLControl(string: "a~5,'x:@Ab")
    XCTAssertEqual(control.components.count, 3)
    guard case .text(let first) = control.components[0],
          case .directive(let directive) = control.components[1],
          case .text(let last) = control.components[2] else {
      return XCTFail("unexpected components \(control.components)")
    }
    XCTAssertEqual(first, "a")
    XCTAssertEqual(last, "b")
    XCTAssertEqual(directive.parameters, Parameters([.number(5), .character("x")]))
    XCTAssertEqual(directive.modifiers, [.colon, .at])
    XCTAssertEqual(directive.specifier.identifier, "A")
    XCTAssertEqual(directive.description, "~5,'x:@A")
    XCTAssertEqual(control.components[0].description, "\"a\"")
    XCTAssertEqual(control.components[1].description, "~5,'x:@A")
  }

  func testManuallyCreatedControls() throws {
    let directive = Directive(parameters: Parameters([.number(3)]),
                              modifiers: [.at],
                              specifier: StandardDirectiveSpecifier.decimal)
    let control = CLControl(components: [.text("n = "), .directive(directive), .text("!")])
    XCTAssertEqual(try control.format(args: 7), "n =  +7!")
    XCTAssertEqual(try control.format(arguments: [42]), "n = +42!")
    XCTAssertEqual(control.description, "\"n = \", ~3@D, \"!\"")
    XCTAssertTrue(CLControl(components: []).isEmpty)
    XCTAssertEqual(try CLControl(components: []).format(), "")
  }

  func testControlsCanBeReused() throws {
    let control = try CLControl(string: "~D~:P")
    XCTAssertEqual(try control.format(args: 1), "1")
    XCTAssertEqual(try control.format(args: 2), "2s")
    XCTAssertEqual(try control.format(args: 1), "1")
    XCTAssertEqual(try control.format(locale: Locale(identifier: "de_DE"), args: 1_000_000),
                   "1000000s")
  }

  func testLowLevelFormatting() throws {
    let control = try CLControl(string: "abc ~D")
    let result = try control.format(with: Arguments(args: [5]),
                                    in: Context(config: CLFormatConfig.standard))
    XCTAssertEqual(result, .append("abc 5"))
    XCTAssertEqual(result.string, "abc 5")
    // Iteration instructions
    let jump = try CLControl(string: "a~^b")
    XCTAssertEqual(try jump.format(with: Arguments(args: []), in: Context(config: .standard)),
                   .continue("a"))
  }

  func testContexts() throws {
    let context = Context(config: CLFormatConfig.standard)
    XCTAssertEqual(context.current, "")
    let extended = context.drop("ab").drop("cd")
    XCTAssertEqual(extended.current, "abcd")
    XCTAssertEqual(context.current, "", "contexts are values")
    XCTAssertEqual(extended.output.string, "abcd")
    XCTAssertEqual(Context.History.root.string, "")
    XCTAssertEqual(Context.History.frame("x", .frame("y", .root)).string, "yx")
    var other = CLFormatConfig.standard
    other.nilRepresentation = "other"
    let reconfigured = extended.reconfig(other)
    XCTAssertEqual(reconfigured.config.nilRepresentation, "other")
    XCTAssertEqual(reconfigured.current, "abcd")
    XCTAssertEqual(extended.config.nilRepresentation, "nil")
  }

  func testInstructions() throws {
    XCTAssertEqual(Instruction.append("a").string, "a")
    XCTAssertEqual(Instruction.continue("b").string, "b")
    XCTAssertEqual(Instruction.break("c").string, "c")
    XCTAssertNotEqual(Instruction.append("a"), Instruction.continue("a"))
    XCTAssertEqual(Instruction.break("c"), Instruction.break("c"))
  }

  func testDirectiveSpecifierDescriptions() throws {
    XCTAssertEqual(StandardDirectiveSpecifier.decimal.description, "D")
    XCTAssertEqual(StandardDirectiveSpecifier.fixedFloat.description, "F")
    XCTAssertEqual(StandardDirectiveSpecifier.moneyAmount.description, "$")
    XCTAssertEqual(StandardDirectiveSpecifier.tilde.description, "~")
    XCTAssertEqual(StandardDirectiveSpecifier.upAndOut.description, "^")
    let all: [(StandardDirectiveSpecifier, Character)] =
      [(.ascii, "A"), (.write, "W"), (.sexpr, "S"), (.decimal, "D"), (.radix, "R"),
       (.binary, "B"), (.octal, "O"), (.hexadecimal, "X"), (.character, "C"),
       (.fixedFloat, "F"), (.exponentFloat, "E"), (.generalFloat, "G"), (.moneyAmount, "$"),
       (.percent, "%"), (.ampersand, "&"), (.bar, "|"), (.tilde, "~"), (.plural, "P"),
       (.tabular, "T"), (.ignoreArgs, "*"), (.upAndOut, "^"), (.indirection, "?")]
    for (specifier, identifier) in all {
      XCTAssertEqual(specifier.identifier, identifier)
    }
    let control = try CLControl(string: "~(a~)~[x~;y~]~{z~}~<w~>")
    XCTAssertEqual(control.components.count, 4)
    let descriptions = control.components.map(\.description)
    XCTAssertEqual(descriptions[0], "~(\"a\")")
    XCTAssertEqual(descriptions[1], "~[\"x\"| \"y\"]")
    XCTAssertEqual(descriptions[2], "~{\"z\"}")
    XCTAssertEqual(descriptions[3], "~<")
    let forced = try CLControl(string: "~{z~:}")
    XCTAssertEqual(forced.components.map(\.description), ["~{\"z\":}"])
    let withDefault = try CLControl(string: "~[x~:;y~]")
    XCTAssertEqual(withDefault.components.map(\.description), ["~[\"x\"| \"y\":]"])
  }

  // MARK: - Modifiers

  func testModifiers() throws {
    XCTAssertEqual(Modifiers().description, "")
    XCTAssertEqual(Modifiers.colon.description, ":")
    XCTAssertEqual(Modifiers.at.description, "@")
    XCTAssertEqual(Modifiers.plus.description, "+")
    XCTAssertEqual(Modifiers([.colon, .at]).description, ":@")
    XCTAssertEqual(Modifiers([.plus, .at, .colon]).description, ":@+")
    XCTAssertTrue(Modifiers([.colon, .plus]).contains(.plus))
    XCTAssertFalse(Modifiers([.colon, .plus]).contains(.at))
    XCTAssertEqual(Modifiers(rawValue: 0b101), [.colon, .plus])
    XCTAssertEqual(Modifiers.colon.rawValue, 1)
    XCTAssertEqual(Modifiers.at.rawValue, 2)
    XCTAssertEqual(Modifiers.plus.rawValue, 4)
  }

  // MARK: - Parameters

  func testParameters() throws {
    let params = Parameters([.number(5), .character("x"), .none, .nextArgument,
                             .remainingArguments, .number(-3)])
    XCTAssertEqual(params.parameterCount, 6)
    XCTAssertEqual(params.description, "5,'x,,v,#,-3")
    XCTAssertEqual(try params.number(0), 5)
    XCTAssertEqual(try params.character(1), "x")
    XCTAssertNil(try params.number(2))
    XCTAssertNil(try params.character(2))
    XCTAssertNil(try params.number(10), "missing parameters are nil")
    XCTAssertNil(try params.character(10))
    XCTAssertNil(try params.number(-1))
    XCTAssertEqual(try params.number(5, allowNegative: true), -3)
    XCTAssertThrowsError(try params.number(5)) { error in
      XCTAssertEqual((error as? CLFormatError)?.description,
                     "expected parameter 5 to be a non-negative number, instead it is -3")
    }
    XCTAssertThrowsError(try params.number(1)) { error in
      XCTAssertEqual((error as? CLFormatError)?.description,
                     "expected parameter 1 to be a number, instead it is 'x")
    }
    XCTAssertThrowsError(try params.character(0))
    XCTAssertThrowsError(try params.number(3)) { error in
      XCTAssertEqual((error as? CLFormatError)?.description,
                     "expected parameter 3 to be a number, instead it is v")
    }
    XCTAssertTrue(params.parameterProvided(0))
    XCTAssertFalse(params.parameterProvided(2))
    XCTAssertFalse(params.parameterProvided(6))
    XCTAssertFalse(params.parameterProvided(-1))
    XCTAssertEqual(params.parameter(1), .character("x"))
    XCTAssertEqual(params.parameter(2), Parameter.none)
    XCTAssertNil(params.parameter(6))
    XCTAssertNil(params.parameter(-1))
    XCTAssertEqual(Parameters().parameterCount, 0)
    XCTAssertEqual(Parameters().description, "")
    XCTAssertEqual(Parameters([.number(1)]), Parameters([.number(1)]))
    XCTAssertNotEqual(Parameters([.number(1)]), Parameters([.number(2)]))
  }

  func testParametersFromArguments() throws {
    let params = Parameters([.nextArgument, .remainingArguments, .nextArgument, .number(4)])
    let args = Arguments(args: [7, "x", "extra", "more"])
    let processed = try params.process(arguments: args)
    XCTAssertEqual(processed, Parameters([.number(7), .number(3), .character("x"), .number(4)]))
    XCTAssertEqual(args.left, 2, "parameters consume arguments")
    // Nil arguments result in omitted parameters
    let omitted = try Parameters([.nextArgument]).process(arguments: Arguments(args: [nil]))
    XCTAssertEqual(omitted, Parameters([.none]))
    // Parameters cannot be taken from arguments that do not exist
    XCTAssertThrowsError(try Parameters([.nextArgument]).process(arguments: Arguments(args: [])))
  }

  // MARK: - Arguments

  func testArgumentsAccess() throws {
    let args = Arguments(args: [1, "two", nil, 3.5])
    XCTAssertEqual(args.count, 4)
    XCTAssertEqual(args.left, 4)
    XCTAssertEqual(try args.current() as? Int, 1)
    XCTAssertEqual(args.left, 4, "current does not consume")
    XCTAssertEqual(try args.next() as? Int, 1)
    XCTAssertEqual(args.left, 3)
    XCTAssertEqual(try args.next() as? String, "two")
    XCTAssertNil(try args.next() as Any?)
    XCTAssertEqual(try args.next() as? Double, 3.5)
    XCTAssertEqual(args.left, 0)
    XCTAssertEqual(args.count, 4)
    XCTAssertThrowsError(try args.next())
    XCTAssertThrowsError(try args.current())
    XCTAssertThrowsError(try args.nextAsInt())
    XCTAssertThrowsError(try args.nextAsNumber())
    XCTAssertThrowsError(try args.nextAsCharacter())
    XCTAssertThrowsError(try args.nextAsString())
    XCTAssertThrowsError(try args.nextAsArguments())
  }

  func testArgumentsNavigation() throws {
    let args = Arguments(args: [10, 20, 30, 40])
    try args.advance(by: 2)
    XCTAssertEqual(try args.current() as? Int, 30)
    try args.advance(by: -1)
    XCTAssertEqual(try args.current() as? Int, 20)
    XCTAssertThrowsError(try args.advance(by: -2)) { error in
      XCTAssertEqual((error as? CLFormatError)?.description,
                     "cannot access argument -1; only 4 arguments in total")
    }
    XCTAssertThrowsError(try args.advance(by: 4))
    try args.advance(by: 3)
    XCTAssertEqual(args.left, 0)
    try args.jump(to: 1)
    XCTAssertEqual(try args.current() as? Int, 20)
    try args.jump(to: 4)
    XCTAssertEqual(args.left, 0)
    XCTAssertThrowsError(try args.jump(to: 5))
    XCTAssertThrowsError(try args.jump(to: -1))
    // The first argument can be changed (used for iterations)
    try args.jump(to: 2)
    XCTAssertEqual(args.setFirstArg(), 0)
    try args.jump(to: 1)
    XCTAssertEqual(try args.current() as? Int, 40)
    XCTAssertEqual(args.setFirstArg(to: 0), 2)
  }

  func testArgumentsCoercion() throws {
    let args = Arguments(args: [])
    XCTAssertEqual(args.coerceToInt(5), 5)
    XCTAssertEqual(args.coerceToInt(Int64(7)), 7)
    XCTAssertEqual(args.coerceToInt(UInt(8)), 8)
    XCTAssertEqual(args.coerceToInt(UInt64(9)), 9)
    XCTAssertNil(args.coerceToInt(UInt64.max))
    XCTAssertNil(args.coerceToInt(UInt.max))
    XCTAssertNil(args.coerceToInt(2.5))
    XCTAssertNil(args.coerceToInt("5"))
    XCTAssertEqual(args.coerceToBool(true), true)
    XCTAssertEqual(args.coerceToBool(false), false)
    XCTAssertNil(args.coerceToBool(1))
    XCTAssertNil(args.coerceToBool("true"))
    XCTAssertEqual(args.coerceToString("abc"), "abc")
    XCTAssertEqual(args.coerceToString(NSString(string: "ns")), "ns")
    XCTAssertEqual(args.coerceToString(NSMutableString(string: "mutable")), "mutable")
    XCTAssertNil(args.coerceToString(5))
    XCTAssertEqual(args.coerceToCharacter(Character("c")), "c")
    XCTAssertEqual(args.coerceToCharacter("d"), "d")
    XCTAssertNil(args.coerceToCharacter("ef"))
    XCTAssertNil(args.coerceToCharacter(5))
    XCTAssertEqual(args.coerceToNumber(5), Number.int(5))
    XCTAssertEqual(args.coerceToNumber(2.5), Number.double(2.5))
    XCTAssertNil(args.coerceToNumber("5"))
    XCTAssertEqual(args.coerceToArray([1, 2, 3], capAt: 2)?.count, 2)
    XCTAssertEqual(args.coerceToArray([1, 2, 3], capAt: 10)?.count, 3)
    XCTAssertEqual(args.coerceToArray([1, 2, 3], capAt: 0)?.count, 0)
    XCTAssertEqual(args.coerceToArray(1...4, capAt: 10)?.count, 4)
    XCTAssertEqual(args.coerceToArray("abc", capAt: 10)?.count, 3, "strings are sequences")
    XCTAssertNil(args.coerceToArray(5, capAt: 10))
    let optionals = args.coerceToArray([Optional(1), nil, Optional(3)], capAt: 10)
    XCTAssertEqual(optionals?.count, 3)
    XCTAssertNil(optionals?[1] ?? nil)
    XCTAssertEqual(args.coerceToParameter(5), .number(5))
    XCTAssertEqual(args.coerceToParameter("x"), .character("x"))
    XCTAssertEqual(args.coerceToParameter(Character("y")), .character("y"))
    XCTAssertEqual(args.coerceToParameter(""), Parameter.none)
    XCTAssertNil(args.coerceToParameter("xy"))
    XCTAssertNil(args.coerceToParameter(2.5))
    XCTAssertTrue(args.isNil(nil))
    XCTAssertFalse(args.isNil(0))
    XCTAssertTrue(args.isValue(0))
    XCTAssertFalse(args.isValue(nil))
  }

  func testTypedArgumentAccess() throws {
    let args = Arguments(args: [42, 2.5, "text", "c", Character("d"), [1, 2], nil, UInt8(7)])
    XCTAssertEqual(try args.nextAsInt(), 42)
    XCTAssertEqual(try args.nextAsNumber(), Number.double(2.5))
    XCTAssertEqual(try args.nextAsString(), "text")
    XCTAssertEqual(try args.nextAsCharacter(), "c")
    XCTAssertEqual(try args.nextAsCharacter(), "d")
    let nested = try args.nextAsArguments()
    XCTAssertEqual(nested.count, 2)
    XCTAssertEqual(try nested.nextAsInt(), 1)
    XCTAssertEqual(try args.nextAsParameter(), Parameter.none, "nil is an omitted parameter")
    XCTAssertEqual(try args.nextAsNumber(), Number.uint8(7))
    // Errors
    let bad = Arguments(args: ["text", 5, 2.5, "ab", 5])
    XCTAssertThrowsError(try bad.nextAsInt())
    XCTAssertThrowsError(try bad.nextAsString())
    XCTAssertThrowsError(try bad.nextAsInt())
    XCTAssertThrowsError(try bad.nextAsCharacter())
    XCTAssertThrowsError(try bad.nextAsArguments())
    XCTAssertEqual(try Arguments(args: [3]).nextAsParameter(), .number(3))
    XCTAssertEqual(try Arguments(args: ["z"]).nextAsParameter(), .character("z"))
    XCTAssertEqual(try Arguments(args: [nil]).nextAsParameter(), Parameter.none)
    XCTAssertThrowsError(try Arguments(args: []).nextAsParameter())
  }

  func testArgumentsDescription() throws {
    let args = Arguments(locale: Locale(identifier: "en_US"),
                         tabsize: 4,
                         linewidth: 60,
                         args: [1, "two", nil])
    XCTAssertEqual(args.description,
                   "<Arguments: locale = en_US (fixed en_US), tabsize = 4, linewidth = 60, " +
                   "args = [1, two, nil]>")
    _ = try args.next()
    XCTAssertEqual(args.description,
                   "<Arguments: locale = en_US (fixed en_US), tabsize = 4, linewidth = 60, " +
                   "args = [two, nil]>")
    XCTAssertEqual(Arguments(args: []).description,
                   "<Arguments: tabsize = 8, linewidth = 80, args = []>")
  }

  func testNestedArgumentsInheritSettings() throws {
    let args = Arguments(locale: Locale(identifier: "de_DE"),
                         tabsize: 3,
                         linewidth: 40,
                         displayWidth: true,
                         args: [1, 2])
    let nested = args.new(args: [3], numArgumentsLeft: 5)
    XCTAssertEqual(nested.locale?.identifier, "de_DE")
    XCTAssertEqual(nested.tabsize, 3)
    XCTAssertEqual(nested.linewidth, 40)
    XCTAssertTrue(nested.displayWidth, "the display width setting used to get lost")
    XCTAssertEqual(nested.count, 1)
    XCTAssertEqual(nested.numArgumentsLeft, 5)
  }

  func testDisplayWidthInNestedDirectives() throws {
    // The check mark is displayed in two columns. The display width has to be used
    // consistently, also in directives that create nested arguments.
    XCTAssertEqual(try clformat("|~4A|", displayWidth: true, args: "✅"), "|✅  |")
    XCTAssertEqual(try clformat("~{|~4A|~}", displayWidth: true, args: ["✅"]), "|✅  |")
    XCTAssertEqual(try clformat("~:{|~4A|~}", displayWidth: true, args: [["✅"]]), "|✅  |")
    XCTAssertEqual(try clformat("~?", displayWidth: true, args: "|~4A|", ["✅"] as [Any?]),
                   "|✅  |")
    XCTAssertEqual(try clformat("~@?", displayWidth: true, args: "|~4A|", "✅"), "|✅  |")
    XCTAssertEqual(try clformat("~[|~4A|~]", displayWidth: true, args: 0, "✅"), "|✅  |")
    XCTAssertEqual(try clformat("~{|~8<~A~>|~}", displayWidth: true, args: ["✅"]),
                   "|      ✅|")
    XCTAssertEqual(try clformat("~{|~4A|~}", displayWidth: false, args: ["✅"]), "|✅   |")
  }

  // MARK: - Numbers

  func testNumberConstruction() throws {
    XCTAssertEqual(Number(5), Number.int(5))
    XCTAssertEqual(Number(Int16(5)), Number.int16(5))
    XCTAssertEqual(Number(Int32(5)), Number.int32(5))
    XCTAssertEqual(Number(Int64(5)), Number.int64(5))
    XCTAssertEqual(Number(UInt(5)), Number.uint(5))
    XCTAssertEqual(Number(UInt8(5)), Number.uint8(5))
    XCTAssertEqual(Number(UInt16(5)), Number.uint16(5))
    XCTAssertEqual(Number(UInt32(5)), Number.uint32(5))
    XCTAssertEqual(Number(UInt64(5)), Number.uint64(5))
    XCTAssertEqual(Number(Float(2.5)), Number.float(2.5))
    XCTAssertEqual(Number(2.5), Number.double(2.5))
    XCTAssertEqual(Number(Decimal(string: "2.5")!), Number.decimal(Decimal(string: "2.5")!))
    XCTAssertEqual(Number(NSDecimalNumber(string: "2.5")), Number.decimal(Decimal(string: "2.5")!))
    XCTAssertEqual(Number(NSDecimalNumber(value: 7)), Number.int(7), "integral values stay integers")
    XCTAssertEqual(Number(NSNumber(value: 2.5)), Number.float(2.5))
    XCTAssertNil(Number("5"))
    XCTAssertNil(Number(true))
    XCTAssertNil(Number([1]))
    XCTAssertNil(Number(Int8(5)), "not a supported number type")
  }

  func testNumberProperties() throws {
    let integers: [Number] = [.int(1), .int16(1), .int32(1), .int64(1), .uint(1), .uint8(1),
                              .uint16(1), .uint32(1), .uint64(1)]
    for number in integers {
      XCTAssertTrue(number.isInteger, "\(number)")
      XCTAssertFalse(number.isFloatingPointNumber, "\(number)")
      XCTAssertTrue(number.equals(integer: 1), "\(number)")
      XCTAssertFalse(number.equals(integer: 2), "\(number)")
      XCTAssertEqual(number.asDouble, 1.0, "\(number)")
      XCTAssertEqual(number.description, "1")
      XCTAssertEqual(number.nsnumber, NSNumber(value: 1))
      XCTAssertEqual(number.romanNumeral, "I")
    }
    XCTAssertTrue(Number.uint(1).isUnsignedInteger)
    XCTAssertTrue(Number.uint8(1).isUnsignedInteger)
    XCTAssertTrue(Number.uint16(1).isUnsignedInteger)
    XCTAssertTrue(Number.uint32(1).isUnsignedInteger)
    XCTAssertTrue(Number.uint64(1).isUnsignedInteger)
    XCTAssertFalse(Number.int(1).isUnsignedInteger)
    XCTAssertFalse(Number.double(1).isUnsignedInteger)
    let floats: [Number] = [.float(1.5), .double(1.5), .decimal(Decimal(string: "1.5")!)]
    for number in floats {
      XCTAssertFalse(number.isInteger, "\(number)")
      XCTAssertTrue(number.isFloatingPointNumber, "\(number)")
      XCTAssertFalse(number.equals(integer: 1), "floating-point numbers are never equal")
      XCTAssertEqual(number.asDouble, 1.5, "\(number)")
      XCTAssertEqual(number.description, "1.5")
      XCTAssertEqual(number.nsnumber.doubleValue, 1.5)
      XCTAssertEqual(number.romanNumeral, "1.5")
    }
    XCTAssertFalse(Number.double(1.0).equals(integer: 1))
    XCTAssertEqual(Number.int(-5).description, "-5")
    XCTAssertEqual(Number.uint64(UInt64.max).description, "18446744073709551615")
  }

  func testRomanNumerals() throws {
    let expected: [(Int, String)] = [(1, "I"), (2, "II"), (3, "III"), (4, "IV"), (5, "V"),
                                     (9, "IX"), (14, "XIV"), (40, "XL"), (49, "XLIX"),
                                     (90, "XC"), (400, "CD"), (900, "CM"), (1994, "MCMXCIV"),
                                     (2024, "MMXXIV"), (3999, "MMMCMXCIX")]
    for (number, roman) in expected {
      XCTAssertEqual(Number.int(number).romanNumeral, roman)
      XCTAssertEqual(try clformat("~@R", args: number), roman)
    }
    // Numbers that have no roman representation are printed in decimal notation
    XCTAssertEqual(Number.int(0).romanNumeral, "0")
    XCTAssertEqual(Number.int(-4).romanNumeral, "-4")
    XCTAssertEqual(Number.int(4000).romanNumeral, "4000")
    XCTAssertEqual(Number.uint8(200).romanNumeral, "CC")
    XCTAssertEqual(Number.uint64(5000).romanNumeral, "5000")
  }

  func testNumberCodable() throws {
    let numbers: [Number] = [.int(-5), .int16(5), .int32(5), .int64(5), .uint(5), .uint8(5),
                             .uint16(5), .uint32(5), .uint64(5), .float(2.5), .double(2.5),
                             .decimal(Decimal(string: "2.5")!)]
    for number in numbers {
      let data = try JSONEncoder().encode(number)
      XCTAssertEqual(try JSONDecoder().decode(Number.self, from: data), number)
    }
  }

  // MARK: - Helpers

  func testUnwrapping() throws {
    let some: Int? = 3
    let none: Int? = nil
    XCTAssertEqual(some.unwrap() as? Int, 3)
    XCTAssertNil(none.unwrap())
    let nestedSome: Int?? = .some(.some(3))
    let nestedNone: Int?? = .some(nil)
    let outerNone: Int?? = nil
    XCTAssertEqual(nestedSome.unwrapAll() as? Int, 3)
    XCTAssertNil(nestedNone.unwrapAll())
    XCTAssertNil(outerNone.unwrapAll())
    XCTAssertEqual(unwrapAny(5 as Any) as? Int, 5)
    XCTAssertEqual(unwrapAny(some as Any) as? Int, 3)
    XCTAssertNil(unwrapAny(none as Any))
    XCTAssertEqual(unwrapAny("text" as Any) as? String, "text")
  }

  func testCurrentColumn() throws {
    XCTAssertEqual("".currentColumn(), 0)
    XCTAssertEqual("abc".currentColumn(), 3)
    XCTAssertEqual("abc\ndefgh".currentColumn(), 5)
    XCTAssertEqual("abc\n".currentColumn(), 0)
    XCTAssertEqual("\t".currentColumn(tabsize: 4), 4)
    XCTAssertEqual("ab\t".currentColumn(tabsize: 4), 4)
    XCTAssertEqual("abcd\t".currentColumn(tabsize: 4), 8)
    XCTAssertEqual("a\tb".currentColumn(tabsize: 8), 9)
    XCTAssertEqual("\t".currentColumn(tabsize: 0), 1)
    XCTAssertEqual("a\n\tb".currentColumn(tabsize: 4), 5)
  }
}

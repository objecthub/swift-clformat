// swift-tools-version:5.6
//
//  Package.swift
//  CLFormat
//
//  Created by Matthias Zenger on 15/03/2023.
//  Copyright © 2023-2024 Matthias Zenger. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import PackageDescription

let package = Package(
  name: "CLFormat",
  
  platforms: [
    .macOS(.v11),
    .iOS(.v14),
    .tvOS(.v14),
    .watchOS(.v7)
  ],
  
  // Products define the executables and libraries produced by a package, and make them visible
  // to other packages.
  products: [
    .library(name: "CLFormat", targets: ["CLFormat"]),
    .executable(name: "CLFormatTool", targets: ["CLFormatTool"])
  ],
  
  // Dependencies declare other packages that this package depends on.
  // e.g. `.package(url: /* package url */, from: "1.0.0"),`
  dependencies: [
    .package(url: "https://github.com/objecthub/swift-markdownkit.git", from: "1.2.0")
  ],
  
  // Targets are the basic building blocks of a package. A target can define a module or
  // a test suite. Targets can depend on other targets in this package, and on products
  // in packages which this package depends on.
  targets: [
    .target(name: "CLFormat",
            dependencies: [
              .product(name: "MarkdownKit", package: "swift-markdownkit")
            ],
            exclude: [
              "CLFormat.h",
              "CLFormat.docc"
            ]),
    .executableTarget(name: "CLFormatTool",
                      dependencies: [
                        .target(name: "CLFormat")
                      ],
                      exclude: []),
    .testTarget(name: "CLFormatTests",
                dependencies: [
                  .target(name: "CLFormat")
                ]),
  ],
  
  // Required Swift language version.
  swiftLanguageVersions: [.v5]
)

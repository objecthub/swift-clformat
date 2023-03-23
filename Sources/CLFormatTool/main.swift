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
import CLFormat

print(try clformat("~%;;~{~<~%;;~1,50:; ~A~>~^,~}.~%", args: ["one dfdafadf", "two adfadfadf", "three adfdaf adffda", "four adf adfadf adfadf adfaffaf"]))

print(try clformat("~e and ~,4e", args: Double.pi, Double.pi))
print(try clformat("~$ and ~2,4$", args: Double.pi, Double.pi))
print(try clformat("|~10,,,,10@A|", args: "This it!"))
print(try clformat("|~10,,,,10@A|", args: "This was it!"))
print(try clformat("|one~\n  two~\n three~\nfour|"))
print(try clformat("|one~:\n  two~@\n   ~Athree~:\nfour|", args: 101))

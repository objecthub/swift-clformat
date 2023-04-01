//
//  Optional.swift
//  CLFormat
//
//  Created by Matthias Zenger on 01/04/2023.
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

protocol Unwrappable {
  func unwrap() -> Any?
}

extension Optional: Unwrappable {
  func unwrap() -> Any? {
    switch self {
      case .none:
        return nil
      case .some(let value):
        return value
    }
  }
}

func unwrapAny(_ value: Any) -> Any? {
  guard let optional = value as? Unwrappable else {
    return value
  }
  return optional.unwrap()
}

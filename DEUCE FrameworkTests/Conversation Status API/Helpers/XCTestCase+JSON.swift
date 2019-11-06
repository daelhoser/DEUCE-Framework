//
//  XCTestCase+JSON.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 11/6/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

extension XCTestCase {
    func wrapInPayloadAndConvert(array: [[String: Any]]) -> Data {
        let conversations = [ "payload": array]

        return try! JSONSerialization.data(withJSONObject: conversations)
    }
}

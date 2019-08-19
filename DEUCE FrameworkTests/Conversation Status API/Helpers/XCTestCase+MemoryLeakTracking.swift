//
//  XCTestCase+MemoryLeakTracking.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 8/19/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Object should be deallocated", file: file, line: line)
        }
    }
}

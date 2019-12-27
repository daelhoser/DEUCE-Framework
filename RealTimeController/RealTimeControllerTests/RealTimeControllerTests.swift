//
//  RealTimeControllerTests.swift
//  RealTimeControllerTests
//
//  Created by Jose Alvarez on 12/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

import RealTimeController

class RealTimeController {
    let client: ClientSpy
    
    init(client: ClientSpy) {
        self.client = client
    }
}

class RealTimeControllerTests: XCTestCase {
    func test_onInit_doesNotBeginConnection() {
        let client = ClientSpy()
        _ = RealTimeController(client: client)
        
        XCTAssertEqual(client.connectionRequests, 0)
    }
}

class ClientSpy {
    var connectionRequests = 0
}


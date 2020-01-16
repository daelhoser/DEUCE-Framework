//
//  RealTimeControllerTests.swift
//  RealTimeControllerTests
//
//  Created by Jose Alvarez on 12/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

import RealTimeController
import SignalRSwift

protocol RealTimeProxy {
}

protocol RealTimeConnection {
}

final class RealTimeClient {
    let proxy: RealTimeProxy
    let connection: RealTimeConnection
    
    init(proxy: RealTimeProxy, connection: RealTimeConnection) {
        self.proxy = proxy
        self.connection = connection
    }
}

class RealTimeControllerTests: XCTestCase {
    func test_onInit_doesNotConnect() {
        let spy = RealTimeSpy()
        _ = RealTimeClient(proxy: spy, connection: spy)
        
        XCTAssertEqual(spy.connectionRequests, 0)
    }
}

class RealTimeSpy: RealTimeProxy, RealTimeConnection {
    private(set) var connectionRequests = 0
}

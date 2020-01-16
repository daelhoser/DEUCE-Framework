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
import DEUCE_Framework

protocol RealTimeProxy {
}

protocol RealTimeConnection {
    func start()
    var started: (() -> Void)? { set get }
}

final class SignalRClient: RealTimeClient  {
    let proxy: RealTimeProxy
    var connection: RealTimeConnection
    
    init(proxy: RealTimeProxy, connection: RealTimeConnection) {
        self.proxy = proxy
        self.connection = connection
    }
    
    func connectTo(url: URL, result: @escaping (RealTimeClientResult) -> Void) {
        connection.started = {
            result(.connected)
        }

        connection.start()
    }
}

class RealTimeControllerTests: XCTestCase {
    func test_onInit_doesNotConnect() {
        let spy = RealTimeSpy()
        _ = SignalRClient(proxy: spy, connection: spy)
        
        XCTAssertEqual(spy.connectionRequests, 0)
    }
    
    func test_onConnect_ReturnsConnectedResultWhenConnectionSuccessful() {
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(proxy: spy, connection: spy)
                
        var capturedResult: RealTimeClientResult?
        
        let exp = expectation(description: "Waiting to connect")
        
        realTimeClient.connectTo(url: URL(string: "www.google.com")!) { (result) in
            capturedResult = result
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedResult, RealTimeClientResult.connected)
    }
}

class RealTimeSpy: RealTimeProxy, RealTimeConnection {
    private(set) var connectionRequests = 0
    
    // MARK: - RealTimeConnection
    
    var started: (() -> Void)?

    func start() {
        started?()
    }
}


extension RealTimeClientResult: Equatable {
    public static func == (lhs: RealTimeClientResult, rhs: RealTimeClientResult) -> Bool {
        switch (lhs, rhs) {
        case (.connected, .connected):
            return true
        default:
            return false
        }
    }
}

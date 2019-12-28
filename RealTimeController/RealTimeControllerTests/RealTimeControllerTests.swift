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
    
    enum Error: Swift.Error {
        case connectivity
    }
    
    init(client: ClientSpy) {
        self.client = client
    }
    
    func connect(completion: @escaping (Error) -> Void) {
        client.connect(completion: completion)
    }
}

class RealTimeControllerTests: XCTestCase {
    func test_onInit_doesNotBeginConnection() {
        let client = ClientSpy()
        _ = RealTimeController(client: client)
        
        XCTAssertTrue(client.connectionRequests.isEmpty)
    }
    
    func test_onConnect_returnsErrorOnClientError() {
        let client = ClientSpy()
        let sut = RealTimeController(client: client)
        
        var capturedError: RealTimeController.Error?
        
        sut.connect() { error in
            capturedError = error
        }
        
        client.connect(withError: .connectivity)
        
        XCTAssertEqual([capturedError], [RealTimeController.Error.connectivity])
    }
}

class ClientSpy {
    var connectionRequests = [RealTimeController.Error]()
    var completions = [(RealTimeController.Error) -> Void]()
    
    func connect(completion: @escaping (RealTimeController.Error) -> Void) {
        completions.append(completion)
    }
    
    func connect(withError error: RealTimeController.Error, at index: Int = 0) {
        connectionRequests.append(error)
        completions[index](error)
    }
}



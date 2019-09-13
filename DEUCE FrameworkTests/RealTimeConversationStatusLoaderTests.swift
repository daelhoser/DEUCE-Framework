//
//  RealTimeConversationStatusLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 9/2/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

final class RealTimeConversationStatusLoader {
    private let client: RealTimeClientSpy

    init(client: RealTimeClientSpy) {
        self.client = client
    }

    func connect() {
        client.connect()
    }
}

class RealTimeConversationStatusLoaderTests: XCTestCase {
    func test_onInit_doesNotAttemptConnectToClient() {
        let client = RealTimeClientSpy()
        _ = RealTimeConversationStatusLoader(client: client)

        XCTAssertFalse(client.attemptedConnections)
    }

    func test_onConnect_attemptsToMakeAConnection() {
        let client = RealTimeClientSpy()
        let loader = RealTimeConversationStatusLoader(client: client)

        loader.connect()

        XCTAssertTrue(client.attemptedConnections)
    }
}

class RealTimeClientSpy {
    private(set) var attemptedConnections = false

    func connect() {
        attemptedConnections = true
    }
}


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

    func connect(completion: @escaping (Bool, Error?) -> Void) {
        client.connect(completion: completion)
    }
}

class RealTimeConversationStatusLoaderTests: XCTestCase {
    func test_onInit_doesNotAttemptConnectToClient() {
        let (client, _) = makeSUT()

        XCTAssertFalse(client.attemptedConnections)
    }

    func test_onConnect_attemptsToMakeAConnection() {
        let (client, loader) = makeSUT()

        loader.connect { _,_  in }

        XCTAssertTrue(client.attemptedConnections)
    }

    func test_onConnect_notifiesConnectionErrorOnError() {
        let (client, loader) = makeSUT()

        var receivedError: Error!
        let exp = expectation(description: "wait on connect")

        loader.connect { _, error in
            receivedError = error
            exp.fulfill()
        }

        let clientError = NSError(domain: "any error", code: 0)
        client.completesWithError(clientError)

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(clientError, receivedError as NSError)
    }

    func test_onConnect_notifiesConnectedOnClientConnection() {
        let (client, loader) = makeSUT()

        var connected = false
        let exp = expectation(description: "wait on connect")
        loader.connect { isConnected, _ in
            connected = isConnected
            exp.fulfill()
        }
        client.completesWithSuccess()
        wait(for: [exp], timeout: 1.0)

        XCTAssertTrue(connected)
    }

    // MARK - Helper methods
    private func makeSUT() -> (RealTimeClientSpy, RealTimeConversationStatusLoader) {
        let client = RealTimeClientSpy()
        let loader = RealTimeConversationStatusLoader(client: client)

        trackForMemoryLeaks(object: client)
        trackForMemoryLeaks(object: loader)

        return (client, loader)
    }
}

class RealTimeClientSpy {
    private(set) var attemptedConnections = false
    private var completions = [(Bool, Error?) -> Void]()

    func connect(completion: @escaping (Bool, Error?) -> Void) {
        attemptedConnections = true
        completions.append(completion)
    }

    func completesWithError(_ error: NSError, at index: Int = 0) {
        completions[index](false, error)
    }

    func completesWithSuccess(at index: Int = 0) {
        completions[index](true, nil)
    }
}


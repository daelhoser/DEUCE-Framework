//
//  RealTimeConversationsLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 9/2/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

class RealTimeConversationsLoaderTests: XCTestCase {
    func test_onInit_doesNotAttemptConnectToClient() {
        let (client, _) = makeSUT()

        XCTAssertFalse(client.attemptedConnections)
    }

    func test_onConnect_attemptsToMakeAConnection() {
        let (client, loader) = makeSUT()

        loader.listen { _  in }

        XCTAssertTrue(client.attemptedConnections)
    }

    func test_onConnect_notifiesConnectionErrorOnError() {
        let (client, loader) = makeSUT()
        let clientError = NSError(domain: "any error", code: 0)

        expect(sut: loader, toCompleteWith: failure(.connection), when: {
            client.completesWithError(clientError)
        })
    }

    func test_onConnect_notifiesConnectedOnClientConnection() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .connected, when: {
            client.completesWithSuccess()
        })
    }
    
    func test_onDisconnect_notifiesDisconnectedOnClientDisconnection() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .disconnected, when: {
            client.completesWithDisconnected()
        })
    }


    func test_onConnected_notitiesConnectionLostOnConnectionLost() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .connected, when: {
            client.completesWithSuccess()
        })

        let clientError = NSError(domain: "connection lost error", code: 0)
        expect(sut: loader, toCompleteWith: failure(.connection), when: {
            //Note that removing the 'at: 1' parameter causes a memory leak plus an failed test. Review code to better understand.
            client.completesWithError(clientError, at: 1)
        })
    }
    
    func test_onConnected_notifiesConnectionSlowOnConnectionSlow() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .connected, when: {
            client.completesWithSuccess()
        })

        let clientError = NSError(domain: "connection lost error", code: 0)
        expect(sut: loader, toCompleteWith: failure(.connection), when: {
            //Note that removing the 'at: 1' parameter causes a memory leak plus an failed test. Review code to better understand.
            client.completesWithError(clientError, at: 1)
        })
    }

    // MARK - Helper methods
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (RealTimeClientSpy, RealTimeConversationsListener) {
        let client = RealTimeClientSpy()
        let loader = RealTimeConversationsListener(connection: client, url: url)

        trackForMemoryLeaks(object: client, file: file, line: line)
        trackForMemoryLeaks(object: loader, file: file, line: line)

        return (client, loader)
    }

    private func expect(sut: RealTimeConversationsListener, toCompleteWith expectedResult: Status, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting on connection")

        sut.listen { (receivedResult) in
            switch (expectedResult, receivedResult) {
            case (.connected, .connected):
                break
            case (.disconnected, .disconnected):
                break
            case let (.failed(expectedError), .failed(receivedError)):
                XCTAssertEqual(expectedError as! RealTimeConversationsListener.Error, receivedError  as! RealTimeConversationsListener.Error, file: file, line: line)
            case let (.newMessage(expectedMessage), .newMessage(receivedMessage)):
                XCTAssertEqual(expectedMessage, receivedMessage, file: file, line: line)
            default:
                XCTFail("ExpectedResult \(expectedResult) and got receivedResult: \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RealTimeConversationsListener.Error) -> RealTimeConversationsListener.Result {
        return .failed(error)
    }
}

class RealTimeClientSpy: RealTimeConnection {
    var attemptedConnections: Bool {
        return !completions.isEmpty
    }
    private var completions = [(RealTimeConnectionStatus) -> Void]()

    func start(status: @escaping (RealTimeConnectionStatus) -> Void) {
        completions.append(status)
    }
    
    func stop() {
    }

    func completesWithError(_ error: NSError, at index: Int = 0) {
        self.completions[index](.failed(error))
    }

    func completesWithSuccess(at index: Int = 0) {
        completions[index](.connected)
    }
    
    func completesWithDisconnected(at index: Int = 0) {
        completions[index](.disconnected)
    }
    
    func completeWithSlowConnection(at index: Int = 0) {
        completions[index](.slow)
    }
}


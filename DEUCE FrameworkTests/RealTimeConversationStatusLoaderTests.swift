//
//  RealTimeConversationStatusLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 9/2/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

class RealTimeConversationStatusLoaderTests: XCTestCase {
    func test_onInit_doesNotAttemptConnectToClient() {
        let (client, _) = makeSUT()

        XCTAssertFalse(client.attemptedConnections)
    }

    func test_onConnect_attemptsToMakeAConnection() {
        let (client, loader) = makeSUT()

        loader.connect { _  in }

        XCTAssertTrue(client.attemptedConnections)
    }

    func test_onConnect_notifiesConnectionErrorOnError() {
        let (client, loader) = makeSUT()
        let clientError = NSError(domain: "any error", code: 0)

        expect(sut: loader, toCompleteWith: .failed(.connection), when: {
            client.completesWithError(clientError)
        })
    }

    func test_onConnect_notifiesConnectedOnClientConnection() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .connected, when: {
            client.completesWithSuccess()
        })
    }

    func test_onConnected_notitiesConnectionLostOnConnectionLost() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .connected, when: {
            client.completesWithSuccess()
        })

        let clientError = NSError(domain: "connection lost error", code: 0)
        expect(sut: loader, toCompleteWith: .failed(.connection), when: {
            //Note that removing the 'at: 1' parameter causes a memory leak plus an failed test. Review code to better understand.
            client.completesWithError(clientError, at: 1)
        })
    }

    func test_onConnected_notifiesNewMessageOnNewMessageReceived() {
        let (client, loader) = makeSUT()
        let conversationStatus = makeConversation(conversationType: 0, contentType: 0, createdByName: "any name")

        expect(sut: loader, toCompleteWith: .newMessage(conversationStatus.model), when: {
            client.completeWithNewMessage(conversationStatus.json)
        })
    }

    // MARK - Helper methods
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (RealTimeClientSpy, RealTimeConversationStatusLoader) {
        let client = RealTimeClientSpy()
        let loader = RealTimeConversationStatusLoader(client: client)

        trackForMemoryLeaks(object: client, file: file, line: line)
        trackForMemoryLeaks(object: loader, file: file, line: line)

        return (client, loader)
    }

    private func expect(sut: RealTimeConversationStatusLoader, toCompleteWith expectedResult: RealTimeConversationStatusLoader.Status, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting on connection")

        sut.connect { (receivedResult) in
            switch (expectedResult, receivedResult) {
            case (.connected, .connected):
                break
            case let (.failed(expectedError), .failed(receivedError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
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
}

class RealTimeClientSpy: RealTimeClient {
    var attemptedConnections: Bool {
        return !completions.isEmpty
    }
    private var completions = [(RealTimeClientResult) -> Void]()

    func connect(result: @escaping (RealTimeClientResult) -> Void) {
        completions.append(result)
    }

    func completesWithError(_ error: NSError, at index: Int = 0) {
        self.completions[index](.failed(error))
    }

    func completesWithSuccess(at index: Int = 0) {
        completions[index](.connected)
    }

    func completeWithNewMessage(_ message: [String: Any], at index: Int = 0) {
        completions[index](.newMessage(message))
    }
}


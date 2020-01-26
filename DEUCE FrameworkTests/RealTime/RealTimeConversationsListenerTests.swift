//
//  RealTimeConversationsListener.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 1/24/20.
//  Copyright © 2020 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

class RealTimeConversationsListenerTests: XCTestCase {
    func test_onNewMessage_deliversErrorOnInvalidDictionary() {
        let conversationHub = ConversationHubSpy()
        let sut = RealTimeConversationsListener(hub: conversationHub, newMessageEventName: "newMessage")
        
        expect(sut: sut, toCompleteWith: RealTimeConversationsListener.Result.failed(.invalidData)) {
            let invalidDictionary = ["invalid key": "invalid value"]
            conversationHub.completeEvent(with: invalidDictionary)
        }
    }
    
    func test_onNewMessage_deliversItemOnValidDictionary() {
        let conversationHub = ConversationHubSpy()
        let sut = RealTimeConversationsListener(hub: conversationHub, newMessageEventName: "newMessage")
        
        let conversation = makeConversation(conversationType: 0, contentType: 0, createdByName: "Jose")
        
        expect(sut: sut, toCompleteWith: RealTimeConversationsListener.Result.success(conversation.model)) {
            conversationHub.completeEvent(with: conversation.json)
        }
    }
    
    // MARK: - Helper Methods
    
    private func expect(sut: RealTimeConversationsListener, toCompleteWith expectedResult: RealTimeConversationsListener.Result,  file: StaticString = #file, line: UInt = #line, when action: () -> ()) {
        let exp = expectation(description: "Waiting on load")

        sut.listenForNewMessages { (result) in
            switch(expectedResult, result) {
            case (.failed(let expectedError), .failed(let capturedError)):
                XCTAssertEqual(expectedError, capturedError, file: file, line:  line)
            case (.success(let expectedMessage), .success(let capturedMessage)):
                XCTAssertEqual(expectedMessage, capturedMessage, file: file, line:  line)
            default:
                XCTFail("Expected \(expectedResult) and instead got \(result)", file: file, line:  line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }

    class ConversationHubSpy: ConversationsHub {
        var completion: (([Any]) -> Void)?
        func on(eventName: String, handler: @escaping ([Any]) -> Void) {
            completion = handler
        }
        
        // MARK: - Helper Methods
        func completeEvent(with dictionary: [String: Any]) {
            completion?([dictionary])
        }
    }
}

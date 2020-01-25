//
//  RealTimeConversationsListener.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 1/24/20.
//  Copyright © 2020 DEUCE. All rights reserved.
//

import XCTest

protocol ConversationsHub {
    func on(eventName: String, handler: @escaping ([Any]) -> Void)
}

final class RealTimeConversationsListener {
    private let hub: ConversationsHub
    private let newMessageEventName: String
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    init(hub: ConversationsHub, newMessageEventName: String) {
        self.hub = hub
        self.newMessageEventName = newMessageEventName
    }
    
    func listenForNewMessages(completion: @escaping (Error) -> Void) {
        hub.on(eventName: newMessageEventName) { (value) in
            completion(Error.invalidData)
        }
    }
}

class RealTimeConversationsListenerTests: XCTestCase {
    func test_onNewMessage_deliversErrorOnInvalidDictionary() {
        let conversationHub = ConversationHubSpy()
        let sut = RealTimeConversationsListener(hub: conversationHub, newMessageEventName: "newMessage")
        
        var capturedError: RealTimeConversationsListener.Error?
        
        sut.listenForNewMessages { (error) in
            capturedError = error
        }
        
        let invalidDictionary = ["wrong key": "Wrong value"]
        conversationHub.completeEvent(with: invalidDictionary)
        
        XCTAssertEqual(capturedError, RealTimeConversationsListener.Error.invalidData)
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

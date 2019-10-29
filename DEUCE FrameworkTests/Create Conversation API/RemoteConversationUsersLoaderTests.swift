//
//  RemoteConversationUsersLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 10/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

class ConversationUsersLoader {
    init(client: ClientSpy) {

    }
}

class RemoteConversationUsersLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = ClientSpy()
        _ = ConversationUsersLoader(client: client)

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
}

class ClientSpy {
    private(set) var requestedURLs = [URL]()
}


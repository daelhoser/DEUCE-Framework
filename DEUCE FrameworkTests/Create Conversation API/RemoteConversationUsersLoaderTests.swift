//
//  RemoteConversationUsersLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 10/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

class ConversationUsersLoader {
    let url: URL
    let client: ClientSpy

    init(url: URL, client: ClientSpy) {
        self.url = url
        self.client = client
    }

    func load() {
        client.load(url: url)
    }
}

class RemoteConversationUsersLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "http://a-url.com")!
        let client = ClientSpy()
        _ = ConversationUsersLoader(url: url, client: client)

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-url.com")!
        let client = ClientSpy()
        let loader = ConversationUsersLoader(url: url, client: client)

        loader.load()

        XCTAssertEqual(client.requestedURLs.count, 1)
    }
}

class ClientSpy {
    private(set) var requestedURLs = [URL]()

    func load(url: URL) {
        requestedURLs.append(url)
    }
}


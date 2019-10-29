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
        let (client, _) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let (client, loader) = makeSUT()

        loader.load()

        XCTAssertEqual(client.requestedURLs.count, 1)
    }

    func test_load_requestsDataFromURLTwice() {
        let (client, loader) = makeSUT()

        loader.load()
        loader.load()

        XCTAssertEqual(client.requestedURLs.count, 2)
    }

    // MARK: - Helper Methods

    private func makeSUT() -> (ClientSpy, ConversationUsersLoader) {
        let url = URL(string: "http://a-url.com")!
        let client = ClientSpy()
        let loader = ConversationUsersLoader(url: url, client: client)

        return (client, loader)
    }
}

class ClientSpy {
    private(set) var requestedURLs = [URL]()

    func load(url: URL) {
        requestedURLs.append(url)
    }
}


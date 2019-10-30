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

    public enum Error: Swift.Error {
        case connection
        case invalidData
    }

    init(url: URL, client: ClientSpy) {
        self.url = url
        self.client = client
    }

    func load(completion: @escaping (Error) -> Void) {
        client.load(url: url) { (error) in
            completion(.connection)
        }
    }
}

class RemoteConversationUsersLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (client, _) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let (client, loader) = makeSUT()

        loader.load{ _ in }

        XCTAssertEqual(client.requestedURLs.count, 1)
    }

    func test_load_requestsDataFromURLTwice() {
        let (client, loader) = makeSUT()

        loader.load{ _ in }
        loader.load{ _ in }

        XCTAssertEqual(client.requestedURLs.count, 2)
    }

    func test_load_deliversErrorOnClientError() {
        let (client, loader) = makeSUT()

        var capturedError = [ConversationUsersLoader.Error]()

        let exp = expectation(description: "Performing Load")

        loader.load { (error) in
            capturedError.append(error)
            exp.fulfill()
        }

        let clientError = NSError(domain: "any-error", code: 0)
        client.completeWith(error: clientError)

        XCTAssertEqual(capturedError, [.connection])

        wait(for: [exp], timeout: 1.0)
    }

//    func test_load_deliversErrorOnNon200HttpResponse() {
//        let (clients, loader) = makeSUT()
//
//        let samples = [199, 201, 300, 400, 500]
//
//        var capturedErro: Error?
//
//
//
//        samples.enumerated().forEach { (index, sample) in
//            loader.load { (error) in
//                capturedError = error
//            }
//        }
//    }



    // MARK: - Helper Methods

    private func makeSUT() -> (ClientSpy, ConversationUsersLoader) {
        let url = URL(string: "http://a-url.com")!
        let client = ClientSpy()
        let loader = ConversationUsersLoader(url: url, client: client)

        trackForMemoryLeaks(object: client)
        trackForMemoryLeaks(object: loader)

        return (client, loader)
    }
}

class ClientSpy {
    private(set) var requests = [(url: URL, completion: ((Error) -> Void)?)]()

    var requestedURLs: [URL] {
        return requests.map { $0.url }
    }

    func load(url: URL, completion: @escaping (Error) -> Void) {
        self.requests.append((url, completion))
    }

    func completeWith(error: Error) {
        requests[0].completion?(error)
    }
}


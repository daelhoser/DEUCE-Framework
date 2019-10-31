//
//  RemoteConversationUsersLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 10/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

class ConversationUsersLoader {
    let url: URL
    let client: HTTPClient

    public enum Error: Swift.Error {
        case connection
        case invalidData
        case unauthorized
    }

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { (result) in
            switch result {
            case let .success(_, urlResponse):
                if urlResponse.statusCode == 401 {
                    return completion(.unauthorized)
                } else {
                    return completion(.invalidData)
                }
            case .failure:
                return completion(.connection)
            }
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
        let clientError = NSError(domain: "any-error", code: 0)

        expect(sut: loader, toCompleteWith: .connection, when: {
            client.completeWith(error: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (client, loader) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { (index, sample) in
            expect(sut: loader, toCompleteWith: .invalidData, when: {
                client.completeWith(statusCode: sample, data: "any-data".data(using: .utf8)!)
            })
        }
    }

    func test_load_deliversUnAuthorizeErrorOn401HttpResponse() {
        let (client, loader) = makeSUT()
        let unauthorizedStatusCode = 401

        expect(sut: loader, toCompleteWith: .unauthorized, when: {
            client.completeWith(statusCode: unauthorizedStatusCode, data: "any-data".data(using: .utf8)!)
        })
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .invalidData, when: {
            let invalidData = "invalid-Data".data(using: .utf8)!
            client.completeWith(statusCode: 200, data: invalidData)
        })
    }


    // MARK: - Helper Methods

    private func makeSUT() -> (ClientSpy, ConversationUsersLoader) {
        let url = URL(string: "http://a-url.com")!
        let client = ClientSpy()
        let loader = ConversationUsersLoader(url: url, client: client)

        trackForMemoryLeaks(object: client)
        trackForMemoryLeaks(object: loader)

        return (client, loader)
    }

    private func expect(sut: ConversationUsersLoader, toCompleteWith error:ConversationUsersLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting on load")

        sut.load { (receivedError) in
            XCTAssertEqual(error, receivedError, "Expected error \(error), received \(receivedError) instead", file: file, line: line)
        }
        exp.fulfill()

        action()

        wait(for: [exp], timeout: 1.0)
    }
}

class ClientSpy: HTTPClient {
    private(set) var requests = [(url: URL, completion: ((HTTPClientResult) -> Void)?)]()

    var requestedURLs: [URL] {
        return requests.map { $0.url }
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        self.requests.append((url, completion))
    }

    func completeWith(error: Error) {
        requests[0].completion?(.failure(error))
    }

    func completeWith(statusCode code: Int, data: Data) {
        let url = requests[0].url
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!

        requests[0].completion?(.success(data, response))
    }
}


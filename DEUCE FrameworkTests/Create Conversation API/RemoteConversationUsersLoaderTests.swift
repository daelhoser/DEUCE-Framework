//
//  RemoteConversationUsersLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 10/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

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

        expect(sut: loader, toCompleteWith: failure(.connection), when: {
            client.completeWith(error: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (client, loader) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { (index, sample) in
            expect(sut: loader, toCompleteWith: failure(.invalidData), when: {
                client.completeWith(statusCode: sample, data: "any-data".data(using: .utf8)!)
            })
        }
    }

    func test_load_deliversUnAuthorizeErrorOn401HttpResponse() {
        let (client, loader) = makeSUT()
        let unauthorizedStatusCode = 401

        expect(sut: loader, toCompleteWith: failure(.unauthorized), when: {
            client.completeWith(statusCode: unauthorizedStatusCode, data: "any-data".data(using: .utf8)!)
        })
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: failure(.invalidData), when: {
            let invalidData = "invalid-Data".data(using: .utf8)!
            client.completeWith(statusCode: 200, data: invalidData)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .success([]), when: {
            let data =  wrapInPayloadAndConvert(array: [])
            client.completeWith(statusCode: 200, data: data)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONList() {
        let (client, loader) = makeSUT()

        let user1 = makeConversationUserJSON(id: "Id1", displayName: "Jose", thumbnailUrl: nil)
        let user2 = makeConversationUserJSON(id: "Id2", displayName: "Liliana", thumbnailUrl: URL(string: "http://www.a-url.com")!)

        expect(sut: loader, toCompleteWith: .success([user1.model, user2.model]), when: {
            let data = wrapInPayloadAndConvert(array: [user1.json, user2.json])
            client.completeWith(statusCode: 200, data: data)
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

    private func expect(sut: ConversationUsersLoader, toCompleteWith result: ConversationUsersLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting on load")

        sut.load { (receivedResult) in
            switch (result, receivedResult) {
            case let (.failure(error), .failure(receivedError)):
                XCTAssertEqual(error, receivedError, "Expected error \(error), received \(receivedError) instead", file: file, line: line)
            case let (.success(items), .success(receivedItems)):
                XCTAssertEqual(items, receivedItems, "Expected items \(items), received \(receivedItems) instead", file: file, line: line)
            default:
                XCTFail("Expected result \(result), received \(receivedResult) instead", file: file, line: line)
            }
        }
        exp.fulfill()

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: ConversationUsersLoader.Error) -> ConversationUsersLoader.Result {
        return .failure(error)
    }

    private func makeConversationUserJSON(id: String = "123456", displayName: String = "username", thumbnailUrl: URL? = nil) -> (model: ConversationUser, json: [String: Any]) {
        let dictionary: [String: Any?] = [
            "Id": id,
            "DisplayName": displayName,
            "ThumbnailUrl": thumbnailUrl?.absoluteString
        ]

        let reducedDictionary = dictionary.reduce(into: [String: Any]()) { (acc, d) in
            if let value = d.value { acc[d.key] = value }
        }

        let user = ConversationUser(id: id, displayName: displayName, thumbnailURL: thumbnailUrl)

        return (user, reducedDictionary)
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


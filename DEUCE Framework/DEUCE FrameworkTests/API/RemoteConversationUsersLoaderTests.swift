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
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (client, loader) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { (arg) in
            let (_, sample) = arg
            expect(sut: loader, toCompleteWith: failure(.invalidData), when: {
                client.complete(with: sample, data: "any-data".data(using: .utf8)!)
            })
        }
    }

    func test_load_deliversUnAuthorizeErrorOn401HttpResponse() {
        let (client, loader) = makeSUT()
        let unauthorizedStatusCode = 401

        expect(sut: loader, toCompleteWith: failure(.unauthorized), when: {
            client.complete(with: unauthorizedStatusCode, data: "any-data".data(using: .utf8)!)
        })
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: failure(.invalidData), when: {
            let invalidData = "invalid-Data".data(using: .utf8)!
            client.complete(with: 200, data: invalidData)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .success([]), when: {
            let data =  wrapInPayloadAndConvert(array: [])
            client.complete(with: 200, data: data)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONList() {
        let (client, loader) = makeSUT()

        let user1 = makeConversationUserJSON(id: "Id1", displayName: "Jose", thumbnailUrl: nil)
        let user2 = makeConversationUserJSON(id: "Id2", displayName: "Liliana", thumbnailUrl: URL(string: "http://www.a-url.com")!)

        expect(sut: loader, toCompleteWith: .success([user1.model, user2.model]), when: {
            let data = wrapInPayloadAndConvert(array: [user1.json, user2.json])
            client.complete(with: 200, data: data)
        })
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        var sut: RemoteConversationUsersLoader?
        let url = URL(string: "https://any-url.com")!
        let client =  HTTPClientSpy()
        sut = RemoteConversationUsersLoader(url: url, client: client)

        var capturedResults = [RemoteConversationUsersLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(with: 200, data: wrapInPayloadAndConvert(array: []))

        XCTAssertTrue(capturedResults.isEmpty)
    }



    // MARK: - Helper Methods

    private func makeSUT() -> (HTTPClientSpy, RemoteConversationUsersLoader) {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        let loader = RemoteConversationUsersLoader(url: url, client: client)

        trackForMemoryLeaks(object: client)
        trackForMemoryLeaks(object: loader)

        return (client, loader)
    }

    private func expect(sut: RemoteConversationUsersLoader, toCompleteWith result: RemoteConversationUsersLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting on load")

        sut.load { (receivedResult) in
            switch (result, receivedResult) {
            case let (.failure(error as RemoteConversationUsersLoader.Error), .failure(receivedError as RemoteConversationUsersLoader.Error)):
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

    private func failure(_ error: RemoteConversationUsersLoader.Error) -> RemoteConversationUsersLoader.Result {
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

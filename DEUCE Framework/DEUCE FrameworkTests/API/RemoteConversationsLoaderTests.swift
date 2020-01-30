//
//  RemoteConversationsLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 5/7/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

class RemoteConversationsLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _  in }
        sut.load { _  in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { (index, sample) in
            expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
                let data = wrapInPayloadAndConvert(array: [])
                client.complete(with: sample, data: data, at: index)
            })
        }
    }

    func test_load_deliversUnAuthorizeErrorOn401HttpResponse() {
        let (sut, client) = makeSUT()
        let unauthorizedStatusCode = 401

        expect(sut: sut, toCompleteWith: failure(.unauthorized), when: {
            let data = wrapInPayloadAndConvert(array: [])
            client.complete(with: unauthorizedStatusCode, data: data)
        })

    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = "{ invalid JSON }".data(using: .utf8)!
            client.complete(with: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWith: .success([]), when: {
            let JSON = wrapInPayloadAndConvert(array: [])
            client.complete(with: 200, data: JSON)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        //Not sure why adding Date() doesn't work. I need to investigate that and make sure code and test are correct

        let item1 = makeConversation(image: URL(string: "http://a-url"), message: nil, lastMessageUser: "Darren", lastMessageTime: Date.init(timeIntervalSince1970: 234234), conversationType: 1, groupName: nil, contentType: 1, createdByName: "Jim")
        let item2 = makeConversation(image: nil, message: "HELLO", lastMessageUser: "Darren", lastMessageTime: nil, conversationType: 1, groupName: "GPP 101", contentType: 1, createdByName: "Tom")

        let jsonData = wrapInPayloadAndConvert(array: [item1.json, item2.json])

        let items = [item1.model, item2.model]

        expect(sut: sut, toCompleteWith: .success(items), when: {
            client.complete(with: 200, data: jsonData)
        })
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        var sut: RemoteConversationsLoader?
        let url = URL(string: "https://any-url.com")!
        let client =  HTTPClientSpy()
        sut = RemoteConversationsLoader(url: url, client: client)

        var capturedResults = [RemoteConversationsLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(with: 200, data: wrapInPayloadAndConvert(array: []))

        XCTAssertTrue(capturedResults.isEmpty)
    }


    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteConversationsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteConversationsLoader(url: url, client: client)

        trackForMemoryLeaks(object: sut, file: file, line: line)
        trackForMemoryLeaks(object: client, file: file, line: line)

        return (sut, client)
    }

    private func expect(sut: RemoteConversationsLoader, toCompleteWith expectedResult: RemoteConversationsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {

        let exp = expectation(description: "Waiting on load")

        sut.load { (receivedResult) in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedItem), .success(receivedItems)):
                XCTAssertEqual(expectedItem, receivedItems, file: file, line: line)
            case let (.failure(expectedError as RemoteConversationsLoader.Error), .failure(actualError  as RemoteConversationsLoader.Error)):
                XCTAssertEqual(expectedError, actualError, file: file, line: line)
            default:
                XCTFail("ExpectedResult \(expectedResult) and got receivedResult: \(receivedResult)", file: file, line: line)
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RemoteConversationsLoader.Error) -> RemoteConversationsLoader.Result {
        return .failure(error)
    }
}

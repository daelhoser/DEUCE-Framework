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
                let data = makeConversationsJSON(conversations: [])
                client.complete(with: sample, data: data, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data(bytes: "{ invalid JSON }".utf8)
            client.complete(with: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWith: .success([]), when: {
            let JSON = makeConversationsJSON(conversations: [])
            client.complete(with: 200, data: JSON)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        //Adding a Date causes this test to fail eventhough its' technically equal. I need to investigate this a little more.

        let item1 = makeConversation(image: URL(string: "http://a-url"), message: nil, lastMessageUser: "Darren", lastMessageTime: nil, conversationType: 1, groupName: nil, contentType: 1)
        let item2 = makeConversation(image: nil, message: "HELLO", lastMessageUser: "Darren", lastMessageTime: nil, conversationType: 1, groupName: "GPP 101", contentType: 1)

        let jsonData = makeConversationsJSON(conversations: [item1.json, item2.json])

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
        client.complete(with: 200, data: makeConversationsJSON(conversations: []))

        XCTAssertTrue(capturedResults.isEmpty)
    }


    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteConversationsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteConversationsLoader(url: url, client: client)

        testForMemoryLeaks(object: sut, file: file, line: line)
        testForMemoryLeaks(object: client, file: file, line: line)

        return (sut, client)
    }

    private func expect(sut: RemoteConversationsLoader, toCompleteWith expectedResult: RemoteConversationsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {

        let exp = expectation(description: "Waiting on load")

        sut.load { (receivedResult) in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedItem), .success(actualItems)):
                XCTAssertEqual(expectedItem, actualItems, file: file, line: line)
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

    private func makeConversation(id: UUID = UUID(), image: URL? = nil, message: String? = nil, lastMessageUser: String? = nil, lastMessageTime: Date? = nil, conversationType: Int, groupName: String? = nil, contentType: Int) -> (model: Conversation, json: [String: Any]) {

        let conversation = Conversation(id: id, image: image, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType)

        let dict: [String: Any?] = [
            "Id": id.uuidString,
            "OtherUserThumbnailUrl": image?.absoluteString,
            "LastMessage": message,
            "OtherUserName": lastMessageUser,
            "LastMessageTimeStamp":  lastMessageTime != nil ? deuceFormatter.string(from: lastMessageTime!) : nil,
            "ConversationType": conversationType,
            "GroupName": groupName,
            "ContentType": contentType
            ]

        let reductedDict = dict.reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }

        return (conversation, reductedDict)
    }

    private func makeConversationsJSON(conversations: [[String: Any]]) -> Data {
        let conversations = [ "Data": conversations]

        return try! JSONSerialization.data(withJSONObject: conversations)
    }

    private var deuceFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"//2017-03-05T05:03:12.5622336
        formatter.timeZone = TimeZone(abbreviation: "UTC")//NSTimeZone.local

        return formatter
    }

    private func failure(_ error: RemoteConversationsLoader.Error) -> RemoteConversationsLoader.Result {
        return .failure(error)
    }

    private func testForMemoryLeaks(object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Object should be deallocated", file: file, line: line)
        }
    }

    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(with statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!

            messages[index].completion(.success(data, response))
        }
    }
}

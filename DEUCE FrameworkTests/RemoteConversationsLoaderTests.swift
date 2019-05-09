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

        expect(sut: sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500].enumerated()

        samples.forEach { (index, sample) in
            expect(sut: sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(with: sample, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data(bytes: "{ invalid JSON }".utf8)
            client.complete(with: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWith: .success([]), when: {
            let JSON = Data(bytes: "{ \"items\": [] }".utf8)
            client.complete(with: 200, data: JSON)
        })
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteConversationsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteConversationsLoader(url: url, client: client)
        return (sut, client)
    }

    private func expect(sut: RemoteConversationsLoader, toCompleteWith result: RemoteConversationsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteConversationsLoader.Result]()
        sut.load { (result) in
            capturedResults.append(result)
        }

        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }

    private func makeConversation(id: UUID, image: URL? = nil, message: String? = nil, lastMessageUser: String? = nil, lastMessageTime: Date? = nil, conversationType: Int, groupName: String? = nil, contentType: Int) -> (model: Conversation, json: [String: Any]) {

        let conversation = Conversation(id: id, image: image, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType)

        let dict: [String: Any?] = [
            "id": id.uuidString,
            "image": image?.absoluteString,
            "message": message,
            "lastMessageUser": lastMessageUser,
            "lastMessageTime": lastMessageTime?.debugDescription,
            "conversationType": conversationType,
            "groupName": groupName,
            "contentType": contentType
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

        func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!

            messages[index].completion(.success(data, response))
        }
    }
}

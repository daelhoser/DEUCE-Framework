//
//  LoadFeedImageDataFromRemoteUseCaseTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 12/14/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            if case let .failure(error) = result {
                completion(.failure(error))
            }
        }
    }
}

class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {
    func test_onInit_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        
        let anotherURL = URL(string: "another-url")!
        sut.loadImageData(from: anotherURL) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, anotherURL])
    }
    
    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()

        let error = NSError(domain: "any error", code: 0)
        
        expect(sut, toCompleteWith: .failure(error), when: {
            client.completeWith(error: error)
        })
    }
    
    // MARK: - Helper Methods
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(object: sut, file: file, line: line)
        trackForMemoryLeaks(object: client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: ImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func completeWith(error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
}

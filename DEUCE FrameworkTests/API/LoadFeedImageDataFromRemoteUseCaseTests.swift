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
    
    func loadImageData(url: URL) {
        client.get(from: url) { _ in }
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
        
        sut.loadImageData(url: url)

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    // MARK: - Helper Methods
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(object: sut, file: file, line: line)
        trackForMemoryLeaks(object: client, file: file, line: line)
        return (sut, client)
    }
    
}

class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        requestedURLs.append(url)
    }
}

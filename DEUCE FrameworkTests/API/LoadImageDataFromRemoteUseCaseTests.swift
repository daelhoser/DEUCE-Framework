//
//  LoadImageDataFromRemoteUseCaseTests.swift
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
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    class HTTPClientTaskWrapper: ImageDataLoaderTask {
        var task: HTTPClientTask?

        func cancel() {
            task?.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> HTTPClientTaskWrapper {
        let taskWrapper = HTTPClientTaskWrapper()
        
        taskWrapper.task = client.get(from: url) { result in
            switch result {
            case let .success (data, response):
                let isValidResponse = response.statusCode == 200 && !data.isEmpty
                isValidResponse ? completion(.success(data)) : completion(.failure(Error.invalidData))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
        return taskWrapper
    }
}

class LoadImageDataFromRemoteUseCaseTests: XCTestCase {
    func test_onInit_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        let anotherURL = URL(string: "another-url")!
        _ = sut.loadImageData(from: anotherURL) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, anotherURL])
    }
    
    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()

        let error = NSError(domain: "any error", code: 0)
        
        expect(sut, toCompleteWith: .failure(error), when: {
            client.complete(with: error)
        })
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 400, 500, 600]
        let data = "any-data".data(using: .utf8)!
        
        samples.enumerated().forEach { (arg) in
            let (index, code) = arg
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                // Careful in not adding the index parameter. You will face deallocations issues. It is good to invest time in understanding this.
                client.complete(with: code, data: data, at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        let emptyData = "".data(using: .utf8)!
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(with: 200, data: emptyData)
        })
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        
        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(with: 200, data: nonEmptyData)
        })
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-given-url.com")!
        
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
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
        
        _ = sut.loadImageData(from: url) { receivedResult in
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
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> ImageDataLoader.Result {
        return .failure(error)
    }
}

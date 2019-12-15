//
//  URLSessionHTTPClientTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 5/19/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }

    override func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
    }

    func test_getFromURL_performGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 1.0)

        //Fixing data Races Solutions 1-3
    /* // Solution #1
        let exp = expectation(description: "Wait for request")
        exp.expectedFulfillmentCount = 2

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        //the reason we have exp.fullfill 2x is because if we don't it will lead to a race condition. If we don't add it below then it could possibly be that fulfill at top finishes before the sut.get method completes and thus the next test starts and causes a write 'read race' condition
        makeSUT().get(from: url) { _ in exp.fulfill() }

        wait(for: [exp], timeout: 1.0)
         */

        /* // Solution #2
         let exp = expectation(description: "Wait for request")
        let exp2 = expectation(description: "waiting on observer requests")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp2.fulfill()
        }

        //the reason we have exp.fullfill 2x is because if we don't it will lead to a race condition. If we don't add it below then it could possibly be that fulfill at top finishes before the sut.get method completes and thus the next test starts and causes a write 'read race' condition
        makeSUT().get(from: url) { _ in exp.fulfill() }

        wait(for: [exp, exp2], timeout: 1.0)
        */

        /*
        // Solution #3
        let exp = expectation(description: "Wait for request")
        var expectedRequests = [URLRequest]()

        URLProtocolStub.observeRequests { request in
            expectedRequests.append(request)
        }

        //the reason we have exp.fullfill 2x is because if we don't it will lead to a race condition. If we don't add it below then it could possibly be that fulfill at top finishes before the sut.get method completes and thus the next test starts and causes a write 'read race' condition
        makeSUT().get(from: url) { _ in exp.fulfill() }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(expectedRequests.count, 1)
        XCTAssertEqual(expectedRequests[0].url, url)
        XCTAssertEqual(expectedRequests[0].httpMethod, "GET")
        */
    }

    /*func test_RequestWithAdditionalHeaders_performRequestWithAdditionalHeaders() {
        let headers = ["key": "Some value", "another key": "another value"]
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            for key in headers.keys {
                XCTAssertEqual(request.allHTTPHeaderFields?[key], headers[key], "Expected value for  key: \(headers[key] ?? ""): received \(request.allHTTPHeaderFields?[key] ?? "") instead.")
            }
            exp.fulfill()
        }
        let sut = makeSUT()
//        sut.addAdditionalHeaders(headers: headers)
        sut.get(from: anyURL()) { _ in }

        wait(for: [exp], timeout: 1.0)
    }*/

    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)

        XCTAssertEqual(receivedError as NSError?, requestError)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))

    }

    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()

        let receivedValues = resultValuesFor(data: data, response: response, error: nil)

        XCTAssertEqual(receivedValues?.data, data)
        //We can't test the receivedResponse because somehow the framework creates a new response and passes it around
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }

    func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()

        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)

        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        //We can't test the receivedResponse because somehow the framework creates a new response and passes it around
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }


    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(object: sut, file: file, line: line)

        return sut
    }

    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)


        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)

            return nil
        }
    }

    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)

        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }

    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")

        var receivedResult: HTTPClientResult!

        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!

    }

    private func anyData() -> Data {
        return "any data".data(using: .utf8)!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }

    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        private struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
        }

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver =  nil
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            // Not quite sure why we are returning here. Checkout the data races video at min 6.
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }

            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}

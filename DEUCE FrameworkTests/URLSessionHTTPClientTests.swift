//
//  URLSessionHTTPClientTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 5/19/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url) { (_, _, _) in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, with: task)

        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url)


        XCTAssertEqual(task.resumeCallCount, 1)
    }

    // MARK: - Helpers

    private class URLSessionSpy: URLSession {
        private var stubs = [URL: URLSessionDataTask]()

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let task = stubs[url] else {
                fatalError("Expected stub. Received no stub instead")
            }
            return task
        }

        func stub(url: URL, with task: URLSessionDataTask) {
            stubs[url] = task
        }
    }

    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount: Int = 0

        override func resume() {
            resumeCallCount += 1
        }
    }
}

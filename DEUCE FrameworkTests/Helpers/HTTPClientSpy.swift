//
//  HTTPClientSpy.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 12/15/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework

class HTTPClientSpy: HTTPClient, HTTPClientHeaders {
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }

    private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    private(set) var cancelledURLs = [URL]()

    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func addAdditionalHeaders(headers: [String : String]) {
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with statusCode: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        
        messages[index].completion(.success(data, response))
    }
}

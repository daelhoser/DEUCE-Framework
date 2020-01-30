//
//  HTTPClient.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/12/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClientHeaders {
    func addAdditionalHeaders(headers: [String: String])
}

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask
}

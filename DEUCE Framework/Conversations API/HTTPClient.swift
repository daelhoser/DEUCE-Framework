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

public protocol HTTPClient {
    func addAdditionalHeaders(headers: [String: String])
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

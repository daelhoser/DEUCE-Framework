//
//  RemoteConversationsLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/7/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteConversationsLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
        client.get(from: url) { (error, response) in
            if error != nil {
                completion(.connectivity, nil)
            } else if response?.statusCode != 200 {
                completion(.invalidData, nil)
            }
        }
    }
}

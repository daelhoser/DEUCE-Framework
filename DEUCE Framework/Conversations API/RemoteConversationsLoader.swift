//
//  RemoteConversationsLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/7/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public final class RemoteConversationsLoader: ConversationLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = LoadConversationResult<Error>
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] (result) in
            guard self != nil else
            { return }
            switch result {
            case let .success(data, response):
                completion(ConversationsMapper.map(data: data, with: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

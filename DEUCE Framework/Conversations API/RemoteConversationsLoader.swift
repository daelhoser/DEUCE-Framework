//
//  RemoteConversationsLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/7/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public final class RemoteConversationsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([Conversation])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { (result) in
            switch result {
            case let .success(data, response):
                do {
                    let conversations = try ConversationsMapper.map(data: data, response: response)

                    completion(.success(conversations))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

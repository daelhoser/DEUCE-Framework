//
//  RemoteConversationsLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/7/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

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
            case let .success(data, _):
                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.deuceFormatter)
                    let conversationData = try jsonDecoder.decode(ConversationData.self, from: data)
                    completion(.success(conversationData.conversations))
                } catch {
                    print(error)
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct ConversationData: Decodable {
    let conversations: [Conversation]

    private enum CodingKeys: String, CodingKey {
        case conversations = "Data"
    }
}

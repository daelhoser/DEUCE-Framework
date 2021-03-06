//
//  RemoteConversationUsersLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 11/6/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public class RemoteConversationUsersLoader: UsersLoader {
    let url: URL
    let client: HTTPClient

    public enum Error: Swift.Error {
        case connection
        case invalidData
        case unauthorized
    }

    public typealias Result = LoadConversationUsersResult

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] (result) in
            guard self != nil else { return }

            switch result {
            case let .success(data, urlResponse):
                return completion(ConversationUsersMapper.map(response: urlResponse, data: data))
            case .failure:
                // did not reach server
                return completion(.failure(Error.connection))
            }
        }
    }
}

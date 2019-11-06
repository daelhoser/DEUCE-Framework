//
//  ConversationUsersLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 11/6/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public class ConversationUsersLoader {
    let url: URL
    let client: HTTPClient

    public enum Error: Swift.Error {
        case connection
        case invalidData
        case unauthorized
    }

    public enum LoadConversationUsersResult {
        case success([ConversationUser])
        case failure(Error)
    }

    public typealias Result = LoadConversationUsersResult

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { (result) in
            switch result {
            case let .success(data, urlResponse):
                let jsonDecoder = JSONDecoder()

                guard urlResponse.statusCode == 200, let payload = try? jsonDecoder.decode(ConversationUserStatusData.self, from: data) else {
                    if urlResponse.statusCode == 401 {
                        return completion(.failure(.unauthorized))
                    } else {
                        return completion(.failure(.invalidData))
                    }
                }
                return completion(.success(payload.users))
            case .failure:
                // did not reach server
                return completion(.failure(.connection))
            }
        }
    }
}

struct ConversationUserStatusData: Decodable {
    let users: [ConversationUser]

    private enum CodingKeys: String, CodingKey {
        case users = "payload"
    }
}

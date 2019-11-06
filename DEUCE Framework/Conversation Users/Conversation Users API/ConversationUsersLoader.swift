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
                return completion(ConversationUsersLoader.map(response: urlResponse, data: data))
            case .failure:
                // did not reach server
                return completion(.failure(.connection))
            }
        }
    }

    private static func map(response: HTTPURLResponse, data: Data) -> Result {
        if response.statusCode == 401 {
            return .failure(.unauthorized)
        } else if response.statusCode == 200 {
            let jsonDecoder = JSONDecoder()

            guard let payload = try? jsonDecoder.decode(ConversationUserStatusData.self, from: data) else {
                return .failure(.invalidData)
            }

            let users = payload.users.map { return $0.user }

            return .success(users)
        }
        return .failure(.invalidData)
    }

}

private struct ConversationUserStatusData: Decodable {
    let users: [ConvoUser]

    private enum CodingKeys: String, CodingKey {
        case users = "payload"
    }
}

private struct ConvoUser: Decodable {
    private let id: String
    private let displayName: String
    private var thumbnailURL: URL?

    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case displayName = "DisplayName"
        case thumbnailURL = "ThumbnailUrl"
    }

    var user: ConversationUser {
        return ConversationUser(id: id, displayName: displayName, thumbnailURL: thumbnailURL)
    }
}

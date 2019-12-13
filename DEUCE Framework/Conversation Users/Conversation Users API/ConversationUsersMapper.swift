//
//  ConversationUsersMapper.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 11/6/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

internal final class ConversationUsersMapper {
    private struct ConversationUserData: Decodable {
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

    private static let OK_200: Int = 200
    private static let Unauthorized_401: Int = 401

    static func map(response: HTTPURLResponse, data: Data) -> RemoteConversationUsersLoader.Result {
        if response.statusCode == Unauthorized_401 {
            return .failure(.unauthorized)
        } else if response.statusCode == OK_200 {
            let jsonDecoder = JSONDecoder()

            guard let payload = try? jsonDecoder.decode(ConversationUserData.self, from: data) else {
                return .failure(.invalidData)
            }

            let users = payload.users.map { return $0.user }

            return .success(users)
        }
        return .failure(.invalidData)
    }
}

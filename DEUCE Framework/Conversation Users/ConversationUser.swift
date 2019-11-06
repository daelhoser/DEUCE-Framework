//
//  ConversationUser.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 11/6/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public struct ConversationUser: Equatable, Decodable {
    public let id: String
    public let displayName: String
    public var thumbnailURL: URL?

    public init(id: String, displayName: String, thumbnailURL: URL?) {
        self.id = id
        self.displayName = displayName
        self.thumbnailURL = thumbnailURL
    }

    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case displayName = "DisplayName"
        case thumbnailURL = "ThumbnailUrl"
    }
}

//
//  Conversation.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/8/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public struct Conversation: Equatable {
    public let id: UUID
    public let image: URL?
    public let message: String?
    public let lastMessageUser: String?
    public let lastMessageTime: Date?
    public let conversationType: Int
    public let groupName: String?
    public let contentType: Int

    public init(id: UUID, image: URL?, message: String?, lastMessageUser: String?, lastMessageTime: Date?, conversationType: Int, groupName: String?, contentType: Int) {
        self.id = id
        self.image = image
        self.message = message
        self.lastMessageUser = lastMessageUser
        self.lastMessageTime = lastMessageTime
        self.conversationType = conversationType
        self.groupName = groupName
        self.contentType = contentType
    }
}

extension Conversation: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let image = try container.decodeIfPresent(URL.self, forKey: .image)
        let message = try container.decodeIfPresent(String.self, forKey: .message)
        let lastMessageUser = try container.decodeIfPresent(String.self, forKey: .lastMessageUser)
        let lastMessageTime = try container.decodeIfPresent(Date.self, forKey: .lastMessageTime)
        let conversationType = try container.decode(Int.self, forKey: .conversationType)
        let groupName = try container.decodeIfPresent(String.self, forKey: .groupName)
        let contentType = try container.decode(Int.self, forKey: .contentType)

        self.init(id: id, image: image, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType)
    }

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case image = "OtherUserThumbnailUrl"
        case message = "LastMessage"
        case lastMessageUser = "OtherUserName"
        case lastMessageTime = "LastMessageTimeStamp"
        case conversationType = "ConversationType"
        case groupName = "GroupName"
        case contentType = "ContentType"
    }
}

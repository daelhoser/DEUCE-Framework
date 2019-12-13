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
    public let conversationId: UUID
    public let message: String?
    public let lastMessageUser: String?
    public let lastMessageTime: Date?
    public let conversationType: Int
    public let groupName: String?
    public let contentType: Int
    public let otherUserId: UUID? // Used for One on One Conversations
    public let createdByName: String

    public init(id: UUID, image: URL?, conversationId: UUID, message: String?, lastMessageUser: String?, lastMessageTime: Date?, conversationType: Int, groupName: String?, contentType: Int, otherUserId: UUID?, createdByName: String) {
        self.id = id
        self.image = image
        self.conversationId = conversationId
        self.message = message
        self.lastMessageUser = lastMessageUser
        self.lastMessageTime = lastMessageTime
        self.conversationType = conversationType
        self.groupName = groupName
        self.contentType = contentType
        self.otherUserId = otherUserId
        self.createdByName = createdByName
    }
}

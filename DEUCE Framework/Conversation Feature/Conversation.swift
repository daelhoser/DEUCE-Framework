//
//  Conversation.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/8/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public struct Conversation: Equatable {
    let id: UUID
    let image: URL?
    let message: String?
    let lastMessageUser: String?
    let lastMessageTime: Date?
    let conversationType: Int
    let groupName: String?
    let contentType: Int

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

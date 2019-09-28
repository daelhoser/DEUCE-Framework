//
//  XCTestCase+ConversationStatus.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 9/28/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

extension XCTestCase {
    func makeConversation(id: UUID = UUID(), image: URL? = nil, message: String? = nil, lastMessageUser: String? = nil, lastMessageTime: Date? = nil, conversationType: Int, groupName: String? = nil, contentType: Int, conversationId: UUID = UUID(), otherUserId: UUID = UUID(), createdByName: String) -> (model: ConversationStatus, json: [String: Any]) {

        let conversation = ConversationStatus(id: id, image: image, conversationId: conversationId, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType, otherUserId: otherUserId, createdByName: createdByName)

        let dict: [String: Any?] = [
            "Id": id.uuidString,
            "ConversationId": conversationId.uuidString,
            "OtherUserThumbnailUrl": image?.absoluteString,
            "LastMessage": message,
            "OtherUserName": lastMessageUser,
            "LastMessageTimeStamp":  lastMessageTime != nil ? deuceFormatter.string(from: lastMessageTime!) : nil,
            "OtherUserId": otherUserId.uuidString,
            "ConversationType": conversationType,
            "GroupName": groupName,
            "ContentType": contentType,
            "CreatedByUserName": createdByName
        ]

        let reductedDict = dict.reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }

        return (conversation, reductedDict)
    }
}

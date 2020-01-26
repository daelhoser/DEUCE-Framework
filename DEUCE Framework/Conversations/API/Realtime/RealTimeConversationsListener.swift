//
//  RealTimeConversationsListener.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 1/24/20.
//  Copyright © 2020 DEUCE. All rights reserved.
//

import Foundation

public protocol ConversationsHub {
    func on(eventName: String, handler: @escaping ([Any]) -> Void)
}


final public class RealTimeConversationsListener {
    private let hub: ConversationsHub
    private let newMessageEventName: String
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public enum Result {
        case failed(Error)
        case success(Conversation)
    }
    
    public init(hub: ConversationsHub, newMessageEventName: String) {
        self.hub = hub
        self.newMessageEventName = newMessageEventName
    }
    
    public func listenForNewMessages(completion: @escaping (Result) -> Void) {
        hub.on(eventName: newMessageEventName) { (value) in
            guard let first = value.first as? [String: Any] else {
                completion(.failed(RealTimeConversationsListener.Error.invalidData))
                
                return
            }
            completion(RealTimeConversationsListener.map(dictionary: first))
        }
    }
    

    static func map(dictionary: [String: Any]) -> RealTimeConversationsListener.Result {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.deuceFormatter)

        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted), let convo = try? jsonDecoder.decode(ConversationDecodable.self, from: data) else {
            return .failed(Error.invalidData)
        }
        return .success(convo.conversation)
    }

    private struct ConversationDecodable: Equatable, Decodable {
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

        internal init(id: UUID, image: URL?, conversationId: UUID, message: String?, lastMessageUser: String?, lastMessageTime: Date?, conversationType: Int, groupName: String?, contentType: Int, otherUserId: UUID?, createdByName: String) {
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

        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case conversationId = "ConversationId"
            case image = "OtherUserThumbnailUrl"
            case message = "LastMessage"
            case lastMessageUser = "OtherUserName"
            case lastMessageTime = "LastMessageTimeStamp"
            case otherUserId = "OtherUserId"
            case conversationType = "ConversationType"
            case groupName = "GroupName"
            case contentType = "ContentType"
            case createdByUserName = "CreatedByUserName"
        }

        internal init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let id = try container.decode(UUID.self, forKey: .id)
            let conversationId = try container.decode(UUID.self, forKey: .conversationId)
            let image = try container.decodeIfPresent(URL.self, forKey: .image)
            let message = try container.decodeIfPresent(String.self, forKey: .message)
            let lastMessageUser = try container.decodeIfPresent(String.self, forKey: .lastMessageUser)
            let lastMessageTime = try container.decodeIfPresent(Date.self, forKey: .lastMessageTime)
            let otherUserId = try container.decodeIfPresent(UUID.self, forKey: .otherUserId)
            let conversationType = try container.decode(Int.self, forKey: .conversationType)
            let groupName = try container.decodeIfPresent(String.self, forKey: .groupName)
            let contentType = try container.decode(Int.self, forKey: .contentType)
            let createdBy = try container.decode(String.self, forKey: .createdByUserName)

            self.init(id: id, image: image, conversationId: conversationId, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType, otherUserId: otherUserId, createdByName: createdBy)
        }

        var conversation: Conversation {
            return Conversation(id: id, image: image, conversationId: conversationId, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType, otherUserId: otherUserId, createdByName: createdByName)
        }
    }
}

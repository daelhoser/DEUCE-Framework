//
//  RealTimeConversationsListener.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

final public class RealTimeConversationsListener: ConversationsListener {
    private let connection: RealTimeConnection
    private let url: URL

    public enum Error: Swift.Error {
        case connection
        case invalidData
    }

    public typealias Result = Status


    public init(connection: RealTimeConnection, url: URL) {
        self.connection = connection
        self.url = url
    }

    public func listen(completion: @escaping (Result) -> Void) {
        connection.start() { (result) in
            switch result {
            case .connected:
                completion(.connected)
            case .disconnected:
                completion(.disconnected)
            case .slow:
                completion(.slow)
            case .failed:
                completion(.failed(Error.connection))
            case let .newMessage(dictionary):
                completion(RealTimeConversationsListener.map(dictionary: dictionary))
            }
        }
    }

    static func map(dictionary: [String: Any]) -> Status {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.deuceFormatter)

        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted), let convo = try? jsonDecoder.decode(ConversationDecodable.self, from: data) else {
            return .failed(Error.invalidData)
        }
        return .newMessage(convo.conversation)
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

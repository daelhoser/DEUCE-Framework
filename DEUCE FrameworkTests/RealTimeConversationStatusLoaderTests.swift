//
//  RealTimeConversationStatusLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 9/2/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

final class RealTimeConversationStatusLoader {
    private let client: RealTimeClientSpy

    enum Error: Swift.Error {
        case connection
    }

    enum Status {
        case connected
        case failed(Error)
        case newMessage(ConversationStatus)
    }

    init(client: RealTimeClientSpy) {
        self.client = client
    }

    func connect(completion: @escaping (Status) -> Void) {
        client.connect { (connected, error, message) in
            if error != nil {
                completion(.failed(.connection))
            } else if connected != nil {
                completion(.connected)
            } else {
                if let message = message, let conversation = RealTimeConversationStatusLoader.map(dictionary: message) {
                    completion(.newMessage(conversation))
                } else {
                    completion(.failed(.connection))
                }
            }
        }
    }

    static func map(dictionary: [String: Any]) -> ConversationStatus? {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.deuceFormatter)


        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted), let convo = try? jsonDecoder.decode(ConvoStatus.self, from: data) else {
            return nil
        }
        return convo.conversation
    }

    private struct ConvoStatus: Equatable, Decodable {
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

        var conversation: ConversationStatus {
            return ConversationStatus(id: id, image: image, conversationId: conversationId, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType, otherUserId: otherUserId, createdByName: createdByName)
        }
    }
}

//There is a var in the framework already. We are going to move this class to the framework also in the future. As of right now we want to use this.
private extension DateFormatter {
    static var deuceFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"//2017-03-05T05:03:12.5622336
        formatter.timeZone = TimeZone(abbreviation: "UTC")//NSTimeZone.local

        return formatter
    }
}


class RealTimeConversationStatusLoaderTests: XCTestCase {
    func test_onInit_doesNotAttemptConnectToClient() {
        let (client, _) = makeSUT()

        XCTAssertFalse(client.attemptedConnections)
    }

    func test_onConnect_attemptsToMakeAConnection() {
        let (client, loader) = makeSUT()

        loader.connect { _  in }

        XCTAssertTrue(client.attemptedConnections)
    }

    func test_onConnect_notifiesConnectionErrorOnError() {
        let (client, loader) = makeSUT()
        let clientError = NSError(domain: "any error", code: 0)

        expect(sut: loader, toCompleteWith: .failed(.connection), when: {
            client.completesWithError(clientError)
        })
    }

    func test_onConnect_notifiesConnectedOnClientConnection() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .connected, when: {
            client.completesWithSuccess()
        })
    }

    func test_onConnected_notitiesConnectionLostOnConnectionLost() {
        let (client, loader) = makeSUT()

        expect(sut: loader, toCompleteWith: .connected, when: {
            client.completesWithSuccess()
        })

        let clientError = NSError(domain: "connection lost error", code: 0)
        expect(sut: loader, toCompleteWith: .failed(.connection), when: {
            //Note that removing the 'at: 1' parameter causes a memory leak plus an failed test. Review code to better understand.
            client.completesWithError(clientError, at: 1)
        })
    }

    func test_onConnected_notifiesNewMessageOnNewMessageReceived() {
        let (client, loader) = makeSUT()
        let conversationStatus = makeConversation(conversationType: 0, contentType: 0, createdByName: "any name")

        expect(sut: loader, toCompleteWith: .newMessage(conversationStatus.model), when: {
            client.completeWithNewMessage(conversationStatus.json)
        })
    }

    // MARK - Helper methods
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (RealTimeClientSpy, RealTimeConversationStatusLoader) {
        let client = RealTimeClientSpy()
        let loader = RealTimeConversationStatusLoader(client: client)

        trackForMemoryLeaks(object: client, file: file, line: line)
        trackForMemoryLeaks(object: loader, file: file, line: line)

        return (client, loader)
    }

    private func expect(sut: RealTimeConversationStatusLoader, toCompleteWith expectedResult: RealTimeConversationStatusLoader.Status, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting on connection")

        sut.connect { (receivedResult) in
            switch (expectedResult, receivedResult) {
            case (.connected, .connected):
                break
            case let (.failed(expectedError), .failed(receivedError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            case let (.newMessage(expectedMessage), .newMessage(receivedMessage)):
                XCTAssertEqual(expectedMessage, receivedMessage, file: file, line: line)
            default:
                XCTFail("ExpectedResult \(expectedResult) and got receivedResult: \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
}

class RealTimeClientSpy {
    var attemptedConnections: Bool {
        return !completions.isEmpty
    }
    private var completions = [(Bool?, Error?, [String: Any]?) -> Void]()

    func connect(completion: @escaping (Bool?, Error?, [String: Any]?) -> Void) {
        self.completions.append(completion)
    }

    func completesWithError(_ error: NSError, at index: Int = 0) {
        self.completions[index](false, error, nil)
    }

    func completesWithSuccess(at index: Int = 0) {
        completions[index](true, nil, nil)
    }

    func completeWithNewMessage(_ message: [String: Any], at index: Int = 0) {
        completions[index](nil, nil, message)
    }
}


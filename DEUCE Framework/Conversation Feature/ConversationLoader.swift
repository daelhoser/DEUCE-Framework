//
//  ConversationLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/18/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public enum LoadConversationResult {
    case success([Conversation])
    case failure(Error)
}

public protocol ConversationLoader {
    func load(completion: @escaping (LoadConversationResult) -> Void)
}

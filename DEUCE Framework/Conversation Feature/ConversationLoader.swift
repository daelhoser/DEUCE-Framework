//
//  ConversationLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/18/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

enum LoadConversationResult {
    case success([Conversation])
    case error(Error)
}

protocol ConversationLoader {
    func load(completion: @escaping (LoadConversationResult) -> Void)
}

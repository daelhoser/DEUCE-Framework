//
//  ConversationsLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/18/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public enum LoadConversationsResult {
    case success([Conversation])
    case failure(Error)
}

public protocol ConversationsLoader {
    func load(completion: @escaping (LoadConversationsResult) -> Void)
}

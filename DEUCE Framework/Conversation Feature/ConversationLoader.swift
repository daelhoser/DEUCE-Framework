//
//  ConversationLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/18/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public enum LoadConversationResult<Error: Swift.Error> {
    case success([Conversation])
    case failure(Error)
}

extension LoadConversationResult: Equatable where Error: Equatable {}

protocol ConversationLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadConversationResult<Error>) -> Void)
}

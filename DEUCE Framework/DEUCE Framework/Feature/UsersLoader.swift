//
//  UsersLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 12/13/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public enum LoadConversationUsersResult {
    case success([ConversationUser])
    case failure(Error)
}

public protocol UsersLoader {
    func load(completion: @escaping (LoadConversationUsersResult) -> Void)
}

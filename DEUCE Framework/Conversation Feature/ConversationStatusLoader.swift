//
//  ConversationStatusLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/18/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public enum LoadConversationStatusResult {
    case success([ConversationStatus])
    case failure(Error)
}

public protocol ConversationStatusLoader {
    func load(completion: @escaping (LoadConversationStatusResult) -> Void)
}

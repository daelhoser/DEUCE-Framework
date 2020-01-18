//
//  ConversationsListener.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public enum ConnectionStatus {
    case connected
    case disconnected
    case slow
    case failed(Error)
    case newMessage(Conversation)
}

public protocol ConversationsListener {
    func listen(completion: @escaping (ConnectionStatus) -> Void)
}

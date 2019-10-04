//
//  ConversationStatusListener.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public enum Status {
    case connected
    case failed(Error)
    case newMessage(ConversationStatus)
}

public protocol ConversationStatusListener {
    func connect(completion: @escaping (Status) -> Void)
}

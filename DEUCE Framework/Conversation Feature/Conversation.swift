//
//  Conversation.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 5/8/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

struct Conversation {
    let id: UUID
    let image: UIImage?
    let message: String?
    let lastMessageUser: String?
    let lastMessageTimeStamp: Date?
    let conversationType: Int
    let groupName: String?
    let contentType: Int
}

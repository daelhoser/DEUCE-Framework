//
//  ConversationStatusRemoteWithRealTimeLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

final class ConversationStatusRemoteWithRealTimeLoader: ConversationStatusLoader, ConversationStatusRealtimeLoader  {
    private let remoteLoader: ConversationStatusLoader
    private let realtimeLoader: ConversationStatusRealtimeLoader

    init(remoteLoader: ConversationStatusLoader, realtimeLoader: ConversationStatusRealtimeLoader) {
        self.remoteLoader = remoteLoader
        self.realtimeLoader = realtimeLoader
    }

    func load(completion: @escaping (LoadConversationStatusResult) -> Void) {
        remoteLoader.load(completion: completion)
    }

    func connect(completion: @escaping (Status) -> Void) {
        realtimeLoader.connect(completion: completion)
    }
}

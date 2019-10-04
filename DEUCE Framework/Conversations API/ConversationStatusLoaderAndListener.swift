//
//  ConversationStatusLoaderAndListener.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public final class ConversationStatusLoaderAndListener: ConversationStatusLoader, ConversationStatusListener  {
    private let remoteLoader: ConversationStatusLoader
    private let realtimeLoader: ConversationStatusListener

    init(remoteLoader: ConversationStatusLoader, realtimeLoader: ConversationStatusListener) {
        self.remoteLoader = remoteLoader
        self.realtimeLoader = realtimeLoader
    }

    public func load(completion: @escaping (LoadConversationStatusResult) -> Void) {
        remoteLoader.load(completion: completion)
    }

    public func listen(completion: @escaping (Status) -> Void) {
        realtimeLoader.listen(completion: completion)
    }
}

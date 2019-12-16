//
//  ConversationsLoaderAndRealtimeListener.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public final class ConversationsLoaderAndRealtimeListener: ConversationsLoaderAndListener  {
    private let remoteLoader: ConversationsLoader
    private let realtimeLoader: ConversationsListener

    public init(remoteLoader: ConversationsLoader, realtimeLoader: ConversationsListener) {
        self.remoteLoader = remoteLoader
        self.realtimeLoader = realtimeLoader
    }

    public func load(completion: @escaping (LoadConversationsResult) -> Void) {
        remoteLoader.load(completion: completion)
    }

    public func listen(completion: @escaping (Status) -> Void) {
        realtimeLoader.listen(completion: completion)
    }
}

//
//  WebSocketClient.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/2/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public protocol WebSocketClient {
    func start(status: @escaping (WebSocketStatus) -> Void)
    func stop()
}

public enum WebSocketStatus {
    case connected
    case disconnected
    case slow
    case failed(Error)
}

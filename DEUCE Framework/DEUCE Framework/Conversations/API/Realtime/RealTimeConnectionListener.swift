//
//  RealTimeConnectionListener.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

final public class RealTimeConnectionListener: RealTimeConnection {
    private let connection: WebSocketClient

    public enum Error: Swift.Error {
        case connection
    }

    public typealias Status = ConnectionStatus

    public init(connection: WebSocketClient) {
        self.connection = connection
    }

    public func start(status: @escaping (Status) -> Void) {
        connection.start() { (result) in
            switch result {
            case .connected:
                status(.connected)
            case .disconnected:
                status(.disconnected)
            case .slow:
                status(.slow)
            case .failed:
                status(.failed(Error.connection))
            }
        }
    }
    
    public func stop() {
        connection.stop()
    }
}

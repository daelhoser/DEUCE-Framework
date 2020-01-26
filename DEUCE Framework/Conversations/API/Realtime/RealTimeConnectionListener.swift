//
//  RealTimeConnectionListener.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/29/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

final public class RealTimeConnectionListener: ConversationsListener {
    private let connection: RealTimeConnection

    public enum Error: Swift.Error {
        case connection
        case invalidData
    }

    public typealias Status = ConnectionStatus


    public init(connection: RealTimeConnection) {
        self.connection = connection
    }

    public func listen(completion: @escaping (Status) -> Void) {
        connection.start() { (result) in
            switch result {
            case .connected:
                completion(.connected)
            case .disconnected:
                completion(.disconnected)
            case .slow:
                completion(.slow)
            case .failed:
                completion(.failed(Error.connection))
            }
        }
    }
}

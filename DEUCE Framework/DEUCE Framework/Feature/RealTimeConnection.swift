//
//  RealTimeConnection.swift
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
}


/// This is a 'Feature' protocol. This is the contract we choose to work with to get our data to end user. The app. Any other domain needs to comply to this protocol.
public protocol RealTimeConnection {
    func start(status: @escaping (ConnectionStatus) -> Void)
    func stop()
}

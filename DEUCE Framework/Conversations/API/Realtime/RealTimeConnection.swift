//
//  RealTimeConnection.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/2/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public protocol RealTimeConnection {
    func start(status: @escaping (RealTimeConnectionStatus) -> Void)
    func stop()
}

public enum RealTimeConnectionStatus {
    case connected
    case disconnected
    case slow
    case failed(Error)
}

//
//  RealTimeClient.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 9/2/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public protocol RealTimeClient {
    func connectTo(url: URL, result: @escaping (RealTimeClientResult) -> Void)
}

public enum RealTimeClientResult {
    case connected
    case failed(Error)
    case newMessage([String: Any])
}

//
//  RealTimeAzureConnection.swift
//  RealTimeController
//
//  Created by Jose Alvarez on 1/28/20.
//  Copyright © 2020 DEUCE. All rights reserved.
//

import Foundation
import SignalRSwift

extension HubConnection: RealTimeAzureConnection {}

public protocol RealTimeAzureConnection {
    func start()
    func stop()
    var started: (() -> Void)? { set get }
    var error: ((Error) -> Void)? { set get }
    var connectionSlow: (() -> Void)? { set get }
    var closed: (() -> Void)? { set get }
}

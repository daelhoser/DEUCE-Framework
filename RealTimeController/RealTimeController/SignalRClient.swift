//
//  SignalRClient.swift
//  RealTimeController
//
//  Created by Jose Alvarez on 1/28/20.
//  Copyright © 2020 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework

final public class SignalRClient: RealTimeConnection  {
    private var connection: RealTimeAzureConnection
    
    public enum Error: Swift.Error {
        case clientError
    }
    
    public init(connection: RealTimeAzureConnection) {
        self.connection = connection
    }
 
    public func start(status: @escaping (RealTimeConnectionStatus) -> Void) {
        connection.started = {
            status(.connected)
        }
        
        connection.error = { (error) in
            status(.failed(Error.clientError))
        }
        
        connection.connectionSlow = {
            status(.slow)
        }
        
        connection.closed = {
            status(.disconnected)
        }

        connection.start()
    }
    
    public func stop() {
        connection.stop()
    }
}

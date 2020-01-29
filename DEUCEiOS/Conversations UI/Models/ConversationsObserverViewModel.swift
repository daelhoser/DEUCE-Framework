//
//  ConversationsObserverViewModel.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 10/14/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework

final class ConversationsObserverViewModel {
    private let observer: RealTimeConnection

    init(observer: RealTimeConnection) {
        self.observer = observer
    }

    enum ConnectionState {
        case connected
        case disconnected
        case connecting
    }

    var onConnectionStateChange: ((ConnectionState) -> Void)?

    func observe() {
        onConnectionStateChange?(.connecting)

        observer.start(status: { [weak self] (status) in
            guard let self = self else { return }

            switch status {
            case .connected:
                self.onConnectionStateChange?(.connected)
            case .disconnected:
                self.onConnectionStateChange?(.disconnected)
            case .slow:
                break
            case let .failed(error):
                if let error = error as? RealTimeConnectionListener.Error {
                    if case .connection = error {
                        self.onConnectionStateChange?(.disconnected)
                    }
                }
            }
        })
    }
}

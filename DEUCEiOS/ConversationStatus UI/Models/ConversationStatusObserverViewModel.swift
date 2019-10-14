//
//  ConversationStatusObserverViewModel.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 10/14/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework

final class ConversationStatusObserverViewModel {
    private let observer: ConversationStatusListener

    init(observer: ConversationStatusListener) {
        self.observer = observer
    }

    enum ConnectionState {
        case connected
        case disconnected
        case connecting
        case newMessage
    }

    var onConnectionStateChange: ((ConnectionState) -> Void)?

    func observe() {
        onConnectionStateChange?(.connecting)

        observer.listen(completion: { [weak self] (status) in
            guard let self = self else { return }

            switch status {
            case .connected:
                self.onConnectionStateChange?(.connected)
            case let .failed(error):
                if let error = error as? RealTimeConversationStatusLoader.Error {
                    if case .connection = error {
                        self.onConnectionStateChange?(.disconnected)
                    }
                }
            case .newMessage:
                self.onConnectionStateChange?(.newMessage)
            }
        })
    }
}

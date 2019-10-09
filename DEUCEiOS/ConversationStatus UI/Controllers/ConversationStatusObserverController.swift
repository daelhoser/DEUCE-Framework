//
//  ConversationStatusObserverController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 10/9/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework

final public class ConversationStatusObserverController {
    public lazy var retryView: TryAgainView = {
        let view = TryAgainView()
        view.isHidden = true
        view.onRetryButtonTapped = { [weak self] in
            self?.observe()
        }

        return view
    }()

    private let observer: ConversationStatusListener

    var onStatusChange: ((String?) -> Void)?

    init(observer: ConversationStatusListener) {
        self.observer = observer
    }

    func observe() {
        onStatusChange?("connecting...")
        retryView.isHidden = true

        observer.listen(completion: { [weak self] (status) in
            guard let self = self else { return }

            switch status {
            case .connected:
                self.onStatusChange?(nil)
            case let .failed(error):
                if let error = error as? RealTimeConversationStatusLoader.Error {
                    if case .connection = error {
                        self.onStatusChange?("disconnected")
                        self.retryView.isHidden = false
                    } else {
                        self.onStatusChange?(nil)
                    }
                }
            case .newMessage:
                self.onStatusChange?(nil)
            }
        })
    }
}

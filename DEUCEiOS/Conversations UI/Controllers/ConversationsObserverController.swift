//
//  ConversationsObserverController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 10/9/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

final public class ConversationsObserverController {
    public lazy var retryView: TryAgainView = binded(view: TryAgainView())

    private let viewmodel: ConversationsObserverViewModel

    var onStatusChange: ((String?) -> Void)?

    init(viewmodel: ConversationsObserverViewModel) {
        self.viewmodel = viewmodel
    }

    func observe() {
        viewmodel.observe()
    }

    func binded(view: TryAgainView) -> TryAgainView {
        view.isHidden = true

        viewmodel.onConnectionStateChange = { [weak self, weak view] (status) in
            view?.isHidden = true

            switch status {
            case .connected:
                self?.onStatusChange?(nil)
            case .connecting:
                self?.onStatusChange?("connecting...")
            case .disconnected:
                view?.isHidden = false
                self?.onStatusChange?("disconnected")
            case .newMessage:
                self?.onStatusChange?(nil)
            }
        }

        view.onRetryButtonTapped = { [weak self] in
            self?.observe()
        }

        return view
    }
}

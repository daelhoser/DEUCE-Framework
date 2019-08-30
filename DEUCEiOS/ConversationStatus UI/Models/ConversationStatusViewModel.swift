//
//  ConversationStatusViewModel.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/30/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework

final class ConversationStatusViewModel {
    typealias Observer<T> = ((T) -> Void)
    private let loader: ConversationStatusLoader

    init(loader: ConversationStatusLoader) {
        self.loader = loader
    }

    var onLoadingStateChange: Observer<Bool>?
    var onConversationStatusLoad: Observer<[ConversationStatus]>?

    func loadConversationStatuses() {
        onLoadingStateChange?(true)
        loader.load() { [weak self] result in
            if case let .success(conversationStatuses) = result {
                self?.onConversationStatusLoad?(conversationStatuses)
            }
            self?.onLoadingStateChange?(false)

        }
    }
}

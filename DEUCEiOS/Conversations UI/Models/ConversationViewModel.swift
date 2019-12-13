//
//  ConversationViewModel.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/30/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework

final class ConversationViewModel {
    typealias Observer<T> = ((T) -> Void)
    private let loader: ConversationsLoader

    init(loader: ConversationsLoader) {
        self.loader = loader
    }

    var onLoadingStateChange: Observer<Bool>?
    var onConversationLoad: Observer<[Conversation]>?

    func loadConversations() {
        onLoadingStateChange?(true)
        loader.load() { [weak self] result in
            if case let .success(conversations) = result {
                self?.onConversationLoad?(conversations)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}

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
    private let loader: ConversationStatusLoader

    init(loader: ConversationStatusLoader) {
        self.loader = loader
    }

    var onChange: ((ConversationStatusViewModel) -> Void)?
    var onConversationStatusLoad: (([ConversationStatus]) -> Void)?

    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }

    func loadConversationStatuses() {
        isLoading = true
        loader.load() { [weak self] result in
            if case let .success(conversationStatuses) = result {
                self?.onConversationStatusLoad?(conversationStatuses)
            }
            self?.isLoading = false
        }
    }
}

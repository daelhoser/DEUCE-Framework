//
//  ConversationStatusRefreshViewController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/30/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import UIKit
import DEUCE_Framework

final class ConversationStatusRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)

        return refreshControl
    }()

    private let loader: ConversationStatusLoader

    init(loader: ConversationStatusLoader) {
        self.loader = loader
    }

    @objc private func didRefresh() {
        load()
    }

    var onRefresh: (([ConversationStatus]) -> Void)?

    func load() {
        view.beginRefreshing()
        loader.load() { [weak self] result in
            if case let .success(conversationStatuses) = result {
                self?.onRefresh?(conversationStatuses)
            }
            self?.view.endRefreshing()
        }
    }
}

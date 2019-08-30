//
//  ConversationStatusRefreshViewController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/30/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import UIKit

final class ConversationStatusRefreshViewController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())

    private let viewModel: ConversationStatusViewModel

    init(viewModel: ConversationStatusViewModel) {
        self.viewModel = viewModel
    }

    @objc private func didRefresh() {
        refresh()
    }

    func refresh() {
        viewModel.loadConversationStatuses()
    }

    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(didRefresh), for: .valueChanged)

        return view
    }
}

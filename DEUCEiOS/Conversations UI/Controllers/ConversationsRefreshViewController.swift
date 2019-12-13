//
//  ConversationsRefreshViewController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/30/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import UIKit

final class ConversationsRefreshViewController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())

    private let viewModel: ConversationViewModel

    init(viewModel: ConversationViewModel) {
        self.viewModel = viewModel
    }

    @objc private func didRefresh() {
        refresh()
    }

    func refresh() {
        viewModel.loadConversations()
    }

    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(didRefresh), for: .valueChanged)

        return view
    }
}

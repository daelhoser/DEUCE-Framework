//
//  ConversationStatusViewController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import UIKit
import DEUCE_Framework

public final class ConversationStatusViewController: UITableViewController {
    private var loader: ConversationStatusLoader?

    public convenience init(loader: ConversationStatusLoader) {
        self.init()
        self.loader = loader
    }

    override public func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didRefresh), for: .valueChanged)

        load()
    }

    private func load() {
        refreshControl?.beginRefreshing()
        loader?.load() { _ in }
    }

    @objc private func didRefresh() {
        load()
    }
}

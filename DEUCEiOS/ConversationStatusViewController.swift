//
//  ConversationStatusViewController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import UIKit
import DEUCE_Framework

public protocol ImageDataLoader {
    func loadImageData(from url: URL)
}

public final class ConversationStatusViewController: UITableViewController {
    private var tableModel = [ConversationStatus]()
    private var conversationStatusLoader: ConversationStatusLoader?
    private var imageDataLoader: ImageDataLoader?

    public convenience init(conversationStatusLoader: ConversationStatusLoader, imageDataLoader: ImageDataLoader) {
        self.init()
        self.conversationStatusLoader = conversationStatusLoader
        self.imageDataLoader = imageDataLoader
    }

    override public func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didRefresh), for: .valueChanged)

        load()
    }

    private func load() {
        refreshControl?.beginRefreshing()
        conversationStatusLoader?.load() { [weak self] result in
            if case let .success(conversationStatuses) = result {
                self?.tableModel = conversationStatuses
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }

    @objc private func didRefresh() {
        load()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModel[indexPath.row]

        if let url = model.image {
            imageDataLoader?.loadImageData(from: url)
        }
        return UITableViewCell()
    }
}

//
//  ConversationStatusViewController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import UIKit

public final class ConversationStatusViewController: UITableViewController, UITableViewDataSourcePrefetching {
    var tableModel = [ConversationStatusCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    var refreshController: ConversationStatusRefreshViewController?

    convenience init(refreshController: ConversationStatusRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }

    override public func viewDidLoad() {
        refreshControl = refreshController?.view

        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(at: indexPath)
    }

    // MARK: - UITableViewDataSourcePrefetching
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            let controller = cellController(forRowAt: indexPath)
            _ = controller.preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    // MARK: - Helper methods

    private func cellController(forRowAt indexPath: IndexPath) -> ConversationStatusCellController {
        return tableModel[indexPath.row]
    }


    private func cancelCellControllerLoad(at indexPath: IndexPath) {
        let controller = tableModel[indexPath.row]
        controller.cancelLoad()
    }
}

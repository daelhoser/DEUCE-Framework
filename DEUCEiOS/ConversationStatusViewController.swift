//
//  ConversationStatusViewController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import UIKit
import DEUCE_Framework

public final class ConversationStatusViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var models = [ConversationStatus]()
    private var refreshController: ConversationStatusRefreshViewController?
    private var imageDataLoaders: ImageDataLoader?
    private var cellControllers: [IndexPath: ConversationStatusCellController] = [:]

    public convenience init(conversationStatusLoader: ConversationStatusLoader, imageDataLoader: ImageDataLoader) {
        self.init()
        self.refreshController = ConversationStatusRefreshViewController(loader: conversationStatusLoader)
        self.imageDataLoaders = imageDataLoader
    }

    override public func viewDidLoad() {
        refreshControl = refreshController?.view

        tableView.prefetchDataSource = self

        refreshController?.onRefresh = { [weak self] conversationStatuses in
            self?.models = conversationStatuses
            self?.tableView.reloadData()
        }

        refreshController?.load()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let controller = ConversationStatusCellController(model: model, imageDataLoader: imageDataLoaders!)

        cellControllers[indexPath] = controller

        return controller.view()
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(at: indexPath)
    }

    // MARK: - UITableViewDataSourcePrefetching
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            let model = models[indexPath.row]
            let controller = ConversationStatusCellController(model: model, imageDataLoader: imageDataLoaders!)
            _ = controller.view()

            cellControllers[indexPath] = controller
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }

    // MARK: - Helper methods

    private func removeCellController(at indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}

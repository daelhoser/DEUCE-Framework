//
//  ConversationStatusViewController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import UIKit
import DEUCE_Framework

public protocol ImageDataLoaderTask {
    func cancel()
}

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}

public final class ConversationStatusViewController: UITableViewController {
    private var tableModel = [ConversationStatus]()
    private var conversationStatusLoader: ConversationStatusLoader?
    private var imageDataLoaders: ImageDataLoader?
    private var imageLoaderTasks: [IndexPath: ImageDataLoaderTask] = [:]

    public convenience init(conversationStatusLoader: ConversationStatusLoader, imageDataLoader: ImageDataLoader) {
        self.init()
        self.conversationStatusLoader = conversationStatusLoader
        self.imageDataLoaders = imageDataLoader
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
        let cell = ConversationStatusCell()
        let model = tableModel[indexPath.row]

        cell.profileImageViewContainer.startShimmering()
        if let url = model.image {
            imageLoaderTasks[indexPath] = imageDataLoaders?.loadImageData(from: url) { [weak cell] (result) in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.profileImageView.image = image

                cell?.profileImageViewContainer.stopShimmering()
            }
        }
        return cell
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let task = imageLoaderTasks[indexPath]
        task?.cancel()
        imageLoaderTasks[indexPath] = nil
    }
}

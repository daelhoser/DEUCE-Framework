//
//  ConversationsViewController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import UIKit

public final class ConversationsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    var tableModel = [ConversationCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    var refreshController: ConversationsRefreshViewController?
    public private(set) var observerController: ConversationsObserverController?
    var headerController: ConversationsHeaderController?

    convenience init(refreshController: ConversationsRefreshViewController, observerController: ConversationsObserverController?) {
        self.init()
        self.refreshController = refreshController
        self.observerController = observerController
        self.headerController = ConversationsHeaderController()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = refreshController?.view
        navigationItem.titleView = headerController?.view
        view.addSubview(observerController!.retryView)

        tableView.prefetchDataSource = self

        observerController?.onStatusChange = { [weak self] state in
            self?.headerController?.update(string: state)
        }

        observerController?.observe()
        refreshController?.refresh()
    }


    /// Update model with controller. If the controller holds a reference to an existing Conversation (unique Conversation ID) then it replaces the old one from the model and adds the new one on top of the stack. If not found on the model then it is just added.
    ///
    /// - Parameter controller: Conversation Cell Controller
    internal func addConversationController(controller: ConversationCellController) {
        let indexOfExistingController = tableModel.lastIndex { (cont) -> Bool in
            return cont.uniqueId == controller.uniqueId
        }

        if let index = indexOfExistingController {
            tableModel.remove(at: index)
        }
        tableModel.append(controller)
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

    private func cellController(forRowAt indexPath: IndexPath) -> ConversationCellController {
        return tableModel[indexPath.row]
    }

    private func cancelCellControllerLoad(at indexPath: IndexPath) {
        let controller = tableModel[indexPath.row]
        controller.cancelLoad()
    }
}
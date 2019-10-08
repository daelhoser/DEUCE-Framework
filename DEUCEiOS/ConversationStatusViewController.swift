//
//  ConversationStatusViewController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import UIKit
import DEUCE_Framework

public final class TryAgainView: UIView {
    private let tryAgainButton = UIButton()

    var onRetryButtonTapped: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        tryAgainButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonTapped() {
        onRetryButtonTapped?()
    }
}

public final class ConversationStatusViewController: UITableViewController, UITableViewDataSourcePrefetching {
    var tableModel = [ConversationStatusCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    var refreshController: ConversationStatusRefreshViewController?
    var conversationStatusListener: ConversationStatusListener?
    public private(set) var header: HeaderView?
    public private(set) var tryAgainView: TryAgainView?

    convenience init(refreshController: ConversationStatusRefreshViewController, conversationStatusListener: ConversationStatusListener?) {
        self.init()
        self.refreshController = refreshController
        self.conversationStatusListener = conversationStatusListener
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = refreshController?.view
        header = HeaderView()
        tryAgainView = TryAgainView(frame: .zero)

        navigationItem.titleView = header

        tableView.prefetchDataSource = self
        refreshController?.refresh()

        observeNewConversationStatuses()
    }

    private func observeNewConversationStatuses() {
        header?.subtitleLabel.text = "connecting..."
        tryAgainView?.isHidden = true

        conversationStatusListener?.listen(completion: { [weak self] (status) in
            guard let self = self else { return }

            switch status {
            case .connected:
                self.header?.subtitleLabel.text = nil
            case let .failed(error):
                if let error = error as? RealTimeConversationStatusLoader.Error {
                    if case .connection = error {
                        self.header?.subtitleLabel.text = "disconnected"
                        self.tryAgainView?.isHidden = false
                    } else {
                        self.header?.subtitleLabel.text = nil
                    }
                }
            case .newMessage:
                self.header?.subtitleLabel.text = nil
            }
        })
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

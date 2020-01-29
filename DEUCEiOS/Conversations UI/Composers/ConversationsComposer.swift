//
//  ConversationsComposer.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/30/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework
import UIKit

public final class ConversationsComposer {
    private init() {}

    public static func conversationsComposedWith(conversationsLoader: ConversationsLoader, realTimeConnection: RealTimeConnection, imageDataLoader: ImageDataLoader) -> UINavigationController {
        let viewModel = ConversationViewModel(loader: conversationsLoader)
        let observerViewModel = RealTimeConnectionObserverViewModel(observer: realTimeConnection)
        let refreshController = ConversationsRefreshViewController(viewModel: viewModel)
        let observerController = ConversationsObserverController(viewmodel: observerViewModel)
        let viewController = ConversationsViewController(refreshController: refreshController, observerController: observerController)
        viewController.refreshController = refreshController

        viewModel.onConversationLoad = adaptConversationsToCellControllers(forwardingTo: viewController, loader: imageDataLoader)
//        observerViewModel.onNewConversation = adaptNewConversationToCellController(forwardingTo: viewController, loader: imageDataLoader)

        return UINavigationController(rootViewController: viewController)
    }

    private static func adaptConversationsToCellControllers(forwardingTo controller: ConversationsViewController, loader: ImageDataLoader) -> ([Conversation]) -> Void {
        return { [weak controller] conversations in
            controller?.tableModel = conversations.map { model in
                let viewModel = ConversationCellViewModel(model: model, imageDataLoader: loader, imageTransformer: UIImage.init)
                return ConversationCellController(viewModel: viewModel)
            }
            controller?.tableView.reloadData()
        }
    }

    private static func adaptNewConversationToCellController(forwardingTo controller: ConversationsViewController, loader: ImageDataLoader)  -> (Conversation) -> Void {
        return { [weak controller] conversation in
            let viewModel = ConversationCellViewModel(model: conversation, imageDataLoader: loader, imageTransformer: UIImage.init)
            controller?.addConversationController(controller: ConversationCellController(viewModel: viewModel))
        }
    }
}

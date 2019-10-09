//
//  ConversationStatusComposer.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/30/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework
import UIKit

public final class ConversationStatusComposer {
    private init() {}

    public static func conversationStatusComposedWith(conversationStatusLoader: ConversationStatusLoaderAndListener, imageDataLoader: ImageDataLoader) -> UINavigationController {
        let viewModel = ConversationStatusViewModel(loader: conversationStatusLoader)
        let refreshController = ConversationStatusRefreshViewController(viewModel: viewModel)
        let observerController = ConversationStatusObserverController(observer: conversationStatusLoader)
        let viewController = ConversationStatusViewController(refreshController: refreshController, observerController: observerController)
        viewController.refreshController = refreshController

        viewModel.onConversationStatusLoad = adaptConversationStatusToCellControllers(forwardingTo: viewController, loader: imageDataLoader)

        return UINavigationController(rootViewController: viewController)
    }

    private static func adaptConversationStatusToCellControllers(forwardingTo controller: ConversationStatusViewController, loader: ImageDataLoader) -> ([ConversationStatus]) -> Void {
        return { [weak controller] conversationStatus in
            controller?.tableModel = conversationStatus.map { model in
                let viewModel = ConversationStatusCellViewModel(model: model, imageDataLoader: loader, imageTransformer: UIImage.init)
                return ConversationStatusCellController(viewModel: viewModel)
            }
        }
    }
}

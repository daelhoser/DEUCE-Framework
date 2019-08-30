//
//  ConversationStatusComposer.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/30/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import DEUCE_Framework

public final class ConversationStatusComposer {
    private init() {}

    public static func conversationStatusComposedWith(conversationStatusLoader: ConversationStatusLoader, imageDataLoader: ImageDataLoader) -> ConversationStatusViewController {
        let refreshController = ConversationStatusRefreshViewController(loader: conversationStatusLoader)

        let viewController = ConversationStatusViewController(refreshController: refreshController)
        viewController.refreshController = refreshController

        refreshController.onRefresh = adaptConversationStatusToCellControllers(forwardingTo: viewController, loader: imageDataLoader)

        return viewController
    }

    private static func adaptConversationStatusToCellControllers(forwardingTo controller: ConversationStatusViewController, loader: ImageDataLoader) -> ([ConversationStatus]) -> Void {
        return { [weak controller] conversationStatus in
            controller?.tableModel = conversationStatus.map { model in
                ConversationStatusCellController(model: model, imageDataLoader: loader)
            }
        }
    }
}

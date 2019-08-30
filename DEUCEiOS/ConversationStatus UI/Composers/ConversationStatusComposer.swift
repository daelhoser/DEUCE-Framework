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

        refreshController.onRefresh = { [weak viewController] conversationStatuses in
            viewController?.tableModel = conversationStatuses.map { model in
                ConversationStatusCellController(model: model, imageDataLoader: imageDataLoader)
            }
        }

        return viewController
    }
}

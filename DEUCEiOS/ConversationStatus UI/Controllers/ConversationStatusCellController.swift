//
//  ConversationStatusCellController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/30/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import UIKit
import DEUCE_Framework

final class ConversationStatusCellController {
    private let model: ConversationStatus
    private let imageDataLoader: ImageDataLoader
    private var task: ImageDataLoaderTask?

    init(model: ConversationStatus, imageDataLoader: ImageDataLoader) {
        self.model = model
        self.imageDataLoader = imageDataLoader
    }

    public func view() -> UITableViewCell {
        let cell = ConversationStatusCell()

        //        cell.initialsLabel =
        cell.nameLabel.text = model.lastMessageUser ?? model.groupName
        cell.messageLabel.text = model.message
        //        cell.dateLabel?.text =
        cell.profileImageViewContainer.startShimmering()
        cell.profileImageRetry.isHidden = true

        let loadImage = { [weak self, weak cell]  in
            guard let url = self?.model.image else { return }

            self?.task = self?.imageDataLoader.loadImageData(from: url) { (result) in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.profileImageView.image = image
                cell?.profileImageRetry.isHidden = image != nil
                cell?.profileImageViewContainer.stopShimmering()
            }
        }

        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    deinit {
        task?.cancel()
    }
}

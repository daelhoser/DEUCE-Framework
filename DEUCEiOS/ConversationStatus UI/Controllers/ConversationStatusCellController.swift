//
//  ConversationStatusCellController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/30/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import UIKit

final class ConversationStatusCellController {
    private let viewModel: ConversationStatusCellViewModel<UIImage>

    var uniqueId: UUID {
        return viewModel.conversationID
    }

    init(viewModel: ConversationStatusCellViewModel<UIImage>) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = binded(cell: ConversationStatusCell())
        viewModel.loadImageData()

        return cell
    }

    func preload() {
        viewModel.loadImageData()
    }

    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }

    private func binded(cell: ConversationStatusCell) -> ConversationStatusCell {
        cell.initialsLabel.text = viewModel.initials
        cell.nameLabel.text = viewModel.userGroupName
        cell.messageLabel.text = viewModel.message
        cell.dateLabel?.text = viewModel.lastMessageTime
        cell.profileImageViewContainer.isShimmering = true
        cell.profileImageRetry.isHidden = true
        cell.profileImageView.image = nil
        cell.onRetry = viewModel.loadImageData

        viewModel.onImageLoad = { [weak cell] image in
            cell?.profileImageView.image = image
        }

        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.profileImageViewContainer.isShimmering = isLoading
        }

        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.profileImageRetry.isHidden = !shouldRetry
        }

        return cell
    }
}

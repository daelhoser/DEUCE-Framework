//
//  ConversationStatusCell.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/28/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import UIKit

public final class ConversationStatusCell: UITableViewCell {
    public var profileImageView: UIImageView! = UIImageView()
    public var profileImageViewContainer: UIView! = UIView()
    public var initialsLabel: UILabel! = UILabel()
    public var nameLabel: UILabel! = UILabel()
    public var messageLabel: UILabel! = UILabel()
    public var dateLabel: UILabel? = UILabel()
    private(set) public lazy var profileImageRetry: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)

        return button
    }()

    var onRetry: (() -> Void)?

    @objc private func retryButtonTapped() {
        onRetry?()
    }
}

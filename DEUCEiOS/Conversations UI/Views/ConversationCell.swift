//
//  ConversationCell.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 8/28/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import UIKit

public final class ConversationCell: UITableViewCell {
    @IBOutlet public weak var profileImageView: UIImageView!
    @IBOutlet public weak var initialsLabel: UILabel!
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet public weak var messageLabel: UILabel!
    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet private(set) weak var profileImageRetry: UIButton!

    var onRetry: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2.0
        profileImageView.layer.borderColor = UIColor.darkGray.cgColor
    }
}

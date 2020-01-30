//
//  ConversationsHeaderController.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 10/9/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

final class ConversationsHeaderController {
    lazy var view: HeaderView = {
        let headerView = HeaderView()

        return headerView
    }()

    func update(string: String?) {
        view.subtitleLabel.text = string
    }
}

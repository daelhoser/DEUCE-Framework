//
//  TryAgainView.swift
//  DEUCEiOS
//
//  Created by Jose Alvarez on 10/8/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import UIKit

public final class TryAgainView: UIView {
    private let tryAgainButton = UIButton()

    public var onRetryButtonTapped: (() -> Void)?

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

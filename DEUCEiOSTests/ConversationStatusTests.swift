//
//  ConversationStatusTests.swift
//  DEUCEiOSTests
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import UIKit

final class ConversationStatusViewController: UIViewController {
    private var loader: LoaderSpy?

    convenience init(loader: LoaderSpy) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        loader?.load()
    }
}

class ConversationStatusTests: XCTestCase {
    func test_init_doesNotLoadConversationStatuses() {
        let loader = LoaderSpy()
        _ = ConversationStatusViewController(loader: loader)

        XCTAssertEqual(loader.requestCount, 0)
    }

    func test_viewDidLoad_loadsConversationStatuses() {
        let loader = LoaderSpy()
        let sut = ConversationStatusViewController(loader: loader)

        //forces view to load
        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.requestCount, 1)
    }
}


final class LoaderSpy {
    var requestCount = 0

    func load() {
        requestCount += 1
    }
}


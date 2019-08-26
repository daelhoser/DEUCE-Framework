//
//  ConversationStatusTests.swift
//  DEUCEiOSTests
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

final class ConversationStatusViewController {
    private var loader: LoaderSpy?

    convenience init(loader: LoaderSpy) {
        self.init()
        self.loader = loader
    }
}

class ConversationStatusTests: XCTestCase {
    func test_init_doesNotLoadConversationStatuses() {
        let loader = LoaderSpy()
        _ = ConversationStatusViewController(loader: loader)

        XCTAssertEqual(loader.requestCount, 0)
    }
}


final class LoaderSpy {
    var requestCount = 0
}


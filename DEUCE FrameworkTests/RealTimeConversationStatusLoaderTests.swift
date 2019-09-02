//
//  RealTimeConversationStatusLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 9/2/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

final class RealTimeConversationStatusLoader {
    let client: RealTimeClientSpy

    init(client: RealTimeClientSpy) {
        self.client = client
    }
}

class RealTimeConversationStatusLoaderTests: XCTestCase {

    func test_init_doesNotReceiveObserveForConversationStatusItems() {
        let client = RealTimeClientSpy()
        let sut = RealTimeConversationStatusLoader(client: client)

        XCTAssertFalse(client.isObserving)
    }

}

class RealTimeClientSpy {
    private(set) var isObserving = false
}


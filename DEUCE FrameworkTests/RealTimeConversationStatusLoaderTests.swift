//
//  RealTimeConversationStatusLoaderTests.swift
//  DEUCE FrameworkTests
//
//  Created by Jose Alvarez on 9/2/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

final class RealTimeConversationStatusLoader {
    private let client: RealTimeClientSpy

    init(client: RealTimeClientSpy) {
        self.client = client
    }
}

class RealTimeConversationStatusLoaderTests: XCTestCase {
}

class RealTimeClientSpy {
}


//
//  ConversationStatusTests.swift
//  DEUCEiOSTests
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework
import DEUCEiOS

class ConversationStatusTests: XCTestCase {
    func test_init_doesNotLoadConversationStatuses() {
        let (loader, _) = makeSUT()

        XCTAssertEqual(loader.requestCount, 0)
    }

    func test_viewDidLoad_loadsConversationStatuses() {
        let (loader, sut) = makeSUT()

        //forces view to load
        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.requestCount, 1)
    }

    func test_pullToRefresh_loadsFeed() {
        let (loader, sut) = makeSUT()
        //forces view to load
        sut.loadViewIfNeeded()

        //pull to refresh
        sut.refreshControl?.allTargets.forEach { (target) in
            sut.refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }

        XCTAssertEqual(loader.requestCount, 2)
    }

    // MARK: - Helper Methods
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoaderSpy, ConversationStatusViewController) {
        let loader = LoaderSpy()
        let sut = ConversationStatusViewController(loader: loader)

        trackForMemoryLeaks(object: loader, file: file, line: line)
        trackForMemoryLeaks(object: sut, file: file, line: line)

        return (loader, sut)
    }
}


final class LoaderSpy: ConversationStatusLoader {
    var requestCount = 0


    func load(completion: @escaping (LoadConversationStatusResult) -> Void) {
        requestCount += 1
    }
}


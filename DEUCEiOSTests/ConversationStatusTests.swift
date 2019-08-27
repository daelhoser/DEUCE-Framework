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

        sut.simulatePullToRefresh()

        XCTAssertEqual(loader.requestCount, 2)

        sut.simulatePullToRefresh()

        XCTAssertEqual(loader.requestCount, 3)
    }

    func test_viewDidLoad_showsLoadingIndicator() {
        let (_, sut) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }

    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()

        loader.complete()

        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }

    func test_pullToRefresh_showsALoadingIndicator() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.complete()

        sut.simulatePullToRefresh()

        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }

    // MARK: - Helper Methods
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoaderSpy, ConversationStatusViewController) {
        let loader = LoaderSpy()
        let sut = ConversationStatusViewController(loader: loader)

        trackForMemoryLeaks(object: loader, file: file, line: line)
        trackForMemoryLeaks(object: sut, file: file, line: line)

        return (loader, sut)
    }

    final class LoaderSpy: ConversationStatusLoader {
        var requestCount = 0
        private var loadRequests = [(LoadConversationStatusResult) -> Void]()

        func load(completion: @escaping (LoadConversationStatusResult) -> Void) {
            requestCount += 1
            loadRequests.append(completion)
        }

        func complete() {
            loadRequests[0](.success([]))
        }
    }
}

private extension ConversationStatusViewController {
    func simulatePullToRefresh() {
        refreshControl?.allTargets.forEach { (target) in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl!.isRefreshing
    }
}




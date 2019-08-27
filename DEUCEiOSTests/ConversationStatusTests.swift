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
    func test_loadConversationStatusAction_requestConversationStatusFromLoader() {
        let (loader, sut) = makeSUT()

        XCTAssertEqual(loader.requestCount, 0, "Expected no loading requests before view is loaded.")

        //forces view to load
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.requestCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedConversationStatusLoad()
        XCTAssertEqual(loader.requestCount, 2, "Expected another loading request once user initiates a reload")

        sut.simulateUserInitiatedConversationStatusLoad()
        XCTAssertEqual(loader.requestCount, 3, "Expected yet another loading request once user initiates another reload")
    }

    func test_loadingConversationStatusIndicator_isVisibleWhileLoadingConversationStatus() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.complete()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once load completes")

        sut.simulateUserInitiatedConversationStatusLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator when user initiates conversation status reload")

        loader.complete(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }

    func test_userConversationStatusRequestAction_hidesLoadingIndicatorOnLoadingCompletion() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.complete(at: 0)
        sut.simulateUserInitiatedConversationStatusLoad()

        loader.complete(at: 1)

        XCTAssertFalse(sut.isShowingLoadingIndicator)
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

        func complete(at index: Int = 0)  {
            loadRequests[index](.success([]))
        }
    }
}

private extension ConversationStatusViewController {
    func simulateUserInitiatedConversationStatusLoad() {
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




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

        loader.completeConversationStatusLoad()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once load completes")

        sut.simulateUserInitiatedConversationStatusLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator when user initiates conversation status reload")

        loader.completeConversationStatusLoad(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }

    func test_loadConversationStatusCompletion_rendersSuccessfullyLoadedConversationStatus() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        assertThat(sut: sut, isRendering: [])
        let date = Date()

        let conversationStatus1 = makeConversationStatus(imageURL: nil, message: "a message", lastMessageUser: "Jose", lastMessageTime: date, conversationType: 0, groupName: nil, contentType: 0, createdByName: "Creator")
        let conversationStatus2 = makeConversationStatus(imageURL: URL(string: "http:a-url.com"), message: nil, lastMessageUser: nil, lastMessageTime: nil, conversationType: 1, groupName: "Group Class", contentType: 0, createdByName: "Group Creator")

        loader.completeConversationStatusLoad(at: 0, with: [conversationStatus1])
        assertThat(sut: sut, isRendering: [conversationStatus1])

        sut.simulateUserInitiatedConversationStatusLoad()
        loader.completeConversationStatusLoad(at: 1, with: [conversationStatus1, conversationStatus2])
        assertThat(sut: sut, isRendering: [conversationStatus1, conversationStatus2])
    }

    // MARK: - Helper Methods
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoaderSpy, ConversationStatusViewController) {
        let loader = LoaderSpy()
        let sut = ConversationStatusViewController(loader: loader)

        trackForMemoryLeaks(object: loader, file: file, line: line)
        trackForMemoryLeaks(object: sut, file: file, line: line)

        return (loader, sut)
    }

    private func makeConversationStatus(id: UUID = UUID(), imageURL: URL?, conversationID: UUID = UUID(), message: String?, lastMessageUser: String?, lastMessageTime: Date?, conversationType: Int, groupName: String?, contentType: Int, otherUserId: UUID = UUID(), createdByName: String) -> ConversationStatus {
        return ConversationStatus(id: id, image: imageURL, conversationId: conversationID, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType, otherUserId: otherUserId, createdByName: createdByName)
    }

    private func assertThat(sut: ConversationStatusViewController, isRendering conversationStatuses: [ConversationStatus], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedConversationStatusViews(), conversationStatuses.count, "Expected \(conversationStatuses.count) convo Statuses, got \(sut.numberOfRenderedConversationStatusViews()) instead.", file: file, line: line)
    }


    final class LoaderSpy: ConversationStatusLoader {
        var requestCount = 0
        private var loadRequests = [(LoadConversationStatusResult) -> Void]()

        func load(completion: @escaping (LoadConversationStatusResult) -> Void) {
            requestCount += 1
            loadRequests.append(completion)
        }

        func completeConversationStatusLoad(at index: Int = 0, with conversationStatuses: [ConversationStatus] = [])  {
            loadRequests[index](.success(conversationStatuses))
        }
    }
}

private extension ConversationStatusViewController {
    func simulateUserInitiatedConversationStatusLoad() {
        refreshControl?.simulateUserInitiatedPullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl!.isRefreshing
    }

    func numberOfRenderedConversationStatusViews() -> Int {
        return tableView.numberOfRows(inSection: conversationSatusesSection)
    }

    private var conversationSatusesSection: Int {
        return 0
    }
}

private extension UIRefreshControl {
    func simulateUserInitiatedPullToRefresh() {
        allTargets.forEach { (target) in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }    }
}




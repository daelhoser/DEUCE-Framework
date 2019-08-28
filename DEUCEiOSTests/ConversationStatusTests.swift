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

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed with error")
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

    func test_loadConversationStatusCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        assertThat(sut: sut, isRendering: [])
        let conversationStatus1 = makeConversationStatus()

        loader.completeConversationStatusLoad(at: 0, with: [conversationStatus1])
        assertThat(sut: sut, isRendering: [conversationStatus1])

        sut.simulateUserInitiatedConversationStatusLoad()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut: sut, isRendering: [conversationStatus1])
    }

    func test_profileImageView_loadsImageUrlWhenVisible() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let conversationStatus1 = makeConversationStatus(imageURL: URL(string: "http:a-url.com"))
        let conversationStatus2 = makeConversationStatus(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationStatusLoad(at: 0, with: [conversationStatus1, conversationStatus2])
        let conversationStatus3 = makeConversationStatus()

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [conversationStatus1.image], "Expected first image URL request once first view becomes visible")

        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [conversationStatus1.image, conversationStatus2.image], "Expected second image URL request once second view also becomes visible")

        sut.simulateUserInitiatedConversationStatusLoad()
        loader.completeConversationStatusLoad(at: 1, with: [conversationStatus3])
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [conversationStatus1.image, conversationStatus2.image], "Expected no new URL requests since previous conversation Status had no image URL")
    }

    func test_profileImageView_cancelsLoadingWhenNotVisibleAnymore() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let conversationStatus1 = makeConversationStatus(imageURL: URL(string: "http:a-url.com"))
        let conversationStatus2 = makeConversationStatus(imageURL: URL(string: "http:another-url.com"))

        loader.completeConversationStatusLoad(at: 0, with: [conversationStatus1, conversationStatus2])

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateFeedImageViewInvisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [conversationStatus1.image], "Expected first image URL request once first view becomes invisible")

        sut.simulateFeedImageViewInvisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [conversationStatus1.image, conversationStatus2.image], "Expected first and second images URL request cancelled after they become invisible")

    }

    func test_profileImageViewLoadingIndicator_isVisibleWhileLoadingImages() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let conversationStatus1 = makeConversationStatus(imageURL: URL(string: "http:a-url.com"))
        let conversationStatus2 = makeConversationStatus(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationStatusLoad(with: [conversationStatus1, conversationStatus2])

        let view1 = sut.simulateFeedImageViewVisible(at: 0)!
        let view2 = sut.simulateFeedImageViewVisible(at: 1)!

        XCTAssertTrue(view1.isShowingLoadingIndicator, "Expected loading indicator for first view while loading first image")
        XCTAssertTrue(view2.isShowingLoadingIndicator, "Expected loading indicator for first view while loading first image")

        loader.completeImageLoading(at: 0)
        XCTAssertFalse(view1.isShowingLoadingIndicator, "Expected no loading indicator after first view loads")
        XCTAssertTrue(view2.isShowingLoadingIndicator, "Expected loading indicator for first view while loading first image")

        loader.completeImageLoading(at: 1)
        XCTAssertFalse(view1.isShowingLoadingIndicator, "Expected no loading indicator after first view loads")
        XCTAssertFalse(view2.isShowingLoadingIndicator, "Expected no loading indicator after second view loads")
    }

    func test_profileImageView_rendersImageLoadedFromURL() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let conversationStatus1 = makeConversationStatus(imageURL: URL(string: "http:a-url.com"))
        let conversationStatus2 = makeConversationStatus(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationStatusLoad(with: [conversationStatus1, conversationStatus2])

        let view1 = sut.simulateFeedImageViewVisible(at: 0)!
        let view2 = sut.simulateFeedImageViewVisible(at: 1)!
        XCTAssertEqual(view1.renderedImage, .none, "expected no image while first image loads")
        XCTAssertEqual(view2.renderedImage, .none, "expected no image while second image loads")

        let imageData1 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(at: 0, with: imageData1)
        XCTAssertEqual(view1.renderedImage, imageData1)
        XCTAssertEqual(view2.renderedImage, .none, "expected no image while second image loads")

        let imageData2 = UIImage.make(withColor: .green).pngData()!
        loader.completeImageLoading(at: 1, with: imageData2)
        XCTAssertEqual(view1.renderedImage, imageData1)
        XCTAssertEqual(view2.renderedImage, imageData2)
    }

    // MARK: - Helper Methods
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoaderSpy, ConversationStatusViewController) {
        let loader = LoaderSpy()
        let sut = ConversationStatusViewController(conversationStatusLoader: loader, imageDataLoader: loader)

        trackForMemoryLeaks(object: loader, file: file, line: line)
        trackForMemoryLeaks(object: sut, file: file, line: line)

        return (loader, sut)
    }

    private func makeConversationStatus(id: UUID = UUID(), imageURL: URL? = nil, conversationID: UUID = UUID(), message: String? = nil, lastMessageUser: String? = nil, lastMessageTime: Date? = nil, conversationType: Int = 0, groupName: String? = nil, contentType: Int = 0, otherUserId: UUID = UUID(), createdByName: String = "creator") -> ConversationStatus {
        return ConversationStatus(id: id, image: imageURL, conversationId: conversationID, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType, otherUserId: otherUserId, createdByName: createdByName)
    }

    private func assertThat(sut: ConversationStatusViewController, isRendering conversationStatuses: [ConversationStatus], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedConversationStatusViews(), conversationStatuses.count, "Expected \(conversationStatuses.count) convo Statuses, got \(sut.numberOfRenderedConversationStatusViews()) instead.", file: file, line: line)
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

    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> ConversationStatusCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: index, section: conversationSatusesSection)

        return dataSource?.tableView(tableView, cellForRowAt: indexPath) as? ConversationStatusCell
    }

    func simulateFeedImageViewInvisible(at index: Int) {
        let view = simulateFeedImageViewVisible(at: index)
        let indexPath = IndexPath(row: index, section: conversationSatusesSection)
        let delegate = tableView.delegate

        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
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
        }
    }
}

private extension ConversationStatusCell {
    var isShowingLoadingIndicator: Bool {
        return profileImageViewContainer.isShimmering
    }

    var renderedImage: Data? {
        return profileImageView.image?.pngData()
    }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}


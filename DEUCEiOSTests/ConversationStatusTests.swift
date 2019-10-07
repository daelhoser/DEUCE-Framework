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
    func test_ViewController_isFirstViewInNavigationController() {
        let (_, sut) = makeSUT()

        XCTAssertNotNil(sut.parent as? UINavigationController, "Expected Conversation Status to be wrapped in NavigationController")
    }

    // MARK: - Conversation Status Loader
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

        let conversationStatus1 = makeConversationStatus(imageURL: nil, message: "a message", lastMessageUser: "Jose Alvarez", lastMessageTime: date, conversationType: 0, groupName: nil, contentType: 0, createdByName: "Creator")
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
//        let view2 = sut.simulateFeedImageViewVisible(at: 1)!

        XCTAssertTrue(view1.isShowingLoadingIndicator, "Expected loading indicator for first view while loading first image")
//        XCTAssertTrue(view2.isShowingLoadingIndicator, "Expected loading indicator for first view while loading first image")

        loader.completeImageLoading(at: 0)
        XCTAssertFalse(view1.isShowingLoadingIndicator, "Expected no loading indicator after first view loads")
//        XCTAssertTrue(view2.isShowingLoadingIndicator, "Expected loading indicator for first view while loading first image")

//        loader.completeImageLoadingWithError(at: 1)
//        XCTAssertFalse(view1.isShowingLoadingIndicator, "Expected no loading indicator after first view loads")
//        XCTAssertFalse(view2.isShowingLoadingIndicator, "Expected no loading indicator after second view loads with Error")
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

    func test_profileImageRetryButton_isVisibleOnImageURLLoadError() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let conversationStatus1 = makeConversationStatus(imageURL: URL(string: "http:a-url.com"))
        let conversationStatus2 = makeConversationStatus(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationStatusLoad(with: [conversationStatus1, conversationStatus2])

        let view1 = sut.simulateFeedImageViewVisible(at: 0)!
        let view2 = sut.simulateFeedImageViewVisible(at: 1)!

        XCTAssertFalse(view1.isShowingRetryAction, "Expected no retry action for first view while first image loads")
        XCTAssertFalse(view2.isShowingRetryAction, "Expected no retry action for second view while second image loads")

        loader.completeImageLoadingWithError(at: 0)
        XCTAssertTrue(view1.isShowingRetryAction, "Expected a retry action for first view after it completes with URL Error")
        XCTAssertFalse(view2.isShowingRetryAction, "Expected no retry action for second view while second image loads")

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertTrue(view1.isShowingRetryAction, "Expected a retry action for first view after it completes with URL Error")
        XCTAssertTrue(view2.isShowingRetryAction, "Expected a retry action for second view after it completes with URL Error")
    }

    func test_profileImageRetryButton_isVisibleOnInvalidImageData() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let conversationStatus1 = makeConversationStatus(imageURL: URL(string: "http:a-url.com"))
        let conversationStatus2 = makeConversationStatus(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationStatusLoad(with: [conversationStatus1, conversationStatus2])

        let view1 = sut.simulateFeedImageViewVisible(at: 0)!
        let view2 = sut.simulateFeedImageViewVisible(at: 1)!

        XCTAssertFalse(view1.isShowingRetryAction, "Expected no retry action for first view while first image loads")
        XCTAssertFalse(view2.isShowingRetryAction, "Expected no retry action for second view while second image loads")

        let invalidData = "Invalid Data".data(using: .utf8)!

        loader.completeImageLoading(at: 0, with: invalidData)
        XCTAssertTrue(view1.isShowingRetryAction, "Expected a retry action for first view after it completes with URL Error")
        XCTAssertFalse(view2.isShowingRetryAction, "Expected no retry action for second view while second image loads")

        loader.completeImageLoading(at: 1, with: invalidData)
        XCTAssertTrue(view1.isShowingRetryAction, "Expected a retry action for first view after it completes with URL Error")
        XCTAssertTrue(view2.isShowingRetryAction, "Expected a retry action for second view after it completes with URL Error")
    }

    func test_profileImageRetryButton_retriesImageLoad() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let conversationStatus1 = makeConversationStatus(imageURL: URL(string: "http:a-url.com"))
        let conversationStatus2 = makeConversationStatus(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationStatusLoad(with: [conversationStatus1, conversationStatus2])

        let view1 = sut.simulateFeedImageViewVisible(at: 0)!
        let view2 = sut.simulateFeedImageViewVisible(at: 1)!
        XCTAssertEqual(loader.loadedImageURLs, [conversationStatus1.image, conversationStatus2.image], "Expected two image URL request for the two visible views")

        loader.completeImageLoadingWithError(at: 0)
        view1.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [conversationStatus1.image, conversationStatus2.image, conversationStatus1.image], "Expected three image URL request for the two visible views")

        loader.completeImageLoadingWithError(at: 1)
        view2.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [conversationStatus1.image, conversationStatus2.image, conversationStatus1.image, conversationStatus2.image], "Expected three image URL request for the 4 visible views")
    }

    func test_profileImageView_preloadsImageURLWhenNearVisible() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let conversationStatus1 = makeConversationStatus(imageURL: URL(string: "http:a-url.com"))
        let conversationStatus2 = makeConversationStatus(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationStatusLoad(with: [conversationStatus1, conversationStatus2])

        sut.simulateFeedImageViewNearlyVisible(at: 0)
        sut.simulateFeedImageViewNearlyVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [conversationStatus1.image, conversationStatus2.image], "Expected two image URL request for the two nearly visible views")
    }

    func test_profileImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let conversationStatus1 = makeConversationStatus(imageURL: URL(string: "http:a-url.com"))
        let conversationStatus2 = makeConversationStatus(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationStatusLoad(with: [conversationStatus1, conversationStatus2])

        sut.simulateFeedImageViewNotVisible(at: 0)
        sut.simulateFeedImageViewNotVisible(at: 1)

        XCTAssertEqual(loader.cancelledImageURLs, [conversationStatus1.image, conversationStatus2.image], "Expected two image URL request cancelled for the two not visible views")
    }

    // MARK: - Conversation Status Listener
    func test_listenForConversationStatus_beginsListeningForConversationStatus() {
        let (loader, sut) = makeSUT()

        XCTAssertEqual(loader.realtimeRequestCount, 0, "Expected no connection requests before view is loaded.")

        //forces view to load
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.realtimeRequestCount, 1, "Expected a connection request once view is loaded")
    }

    func test_StatusView_isVisibleWhileListenerConnects() {
        let (loader, sut) = makeSUT()

        XCTAssertNil(sut.loadingStatus, "Expected status label to be nil")

        //forces view to load
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.loadingStatus, "Loading...", "Expected loading... status while connecting")

        loader.notifyStatusChange(status: .connected)
        XCTAssertNil(sut.loadingStatus, "Expected nil status when connected successfully")

        loader.notifyStatusChange(status: .newMessage(makeConversationStatus()))
        XCTAssertNil(sut.loadingStatus, "Expected nil when a new conversation is received.")

        let error = RealTimeConversationStatusLoader.Error.connection
        loader.notifyStatusChange(status: .failed(error))
        XCTAssertEqual(sut.loadingStatus, "disconnected")

        //receiving a new message after being disconnected is unlikely. Nevertheless, we still want to test.
        loader.notifyStatusChange(status: .newMessage(makeConversationStatus()))
        XCTAssertNil(sut.loadingStatus, "Expected nil when a new conversation is received.")

        //consider this case. Test if needed
        let invalidData = RealTimeConversationStatusLoader.Error.invalidData
        loader.notifyStatusChange(status: .failed(invalidData))
        XCTAssertNil(sut.loadingStatus, "Expected nil when a conversation can't be decoded properly.")

    }

    // MARK: - Helper Methods
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoaderSpy, ConversationStatusViewController) {
        let loader = LoaderSpy()
        let navigationController = ConversationStatusComposer.conversationStatusComposedWith(conversationStatusLoader: loader, imageDataLoader: loader)
        let sut = navigationController.children.first! as! ConversationStatusViewController

        trackForMemoryLeaks(object: navigationController, file: file, line: line)
        trackForMemoryLeaks(object: loader, file: file, line: line)
        trackForMemoryLeaks(object: sut, file: file, line: line)

        return (loader, sut)
    }

    private func makeConversationStatus(id: UUID = UUID(), imageURL: URL? = nil, conversationID: UUID = UUID(), message: String? = nil, lastMessageUser: String? = nil, lastMessageTime: Date? = nil, conversationType: Int = 0, groupName: String? = nil, contentType: Int = 0, otherUserId: UUID = UUID(), createdByName: String = "creator") -> ConversationStatus {
        return ConversationStatus(id: id, image: imageURL, conversationId: conversationID, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType, otherUserId: otherUserId, createdByName: createdByName)
    }

    private func assertThat(sut: ConversationStatusViewController, isRendering conversationStatuses: [ConversationStatus], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedConversationStatusViews(), conversationStatuses.count, "Expected \(conversationStatuses.count) convo Statuses, got \(sut.numberOfRenderedConversationStatusViews()) instead.", file: file, line: line)

        conversationStatuses.enumerated().forEach { (arg) in
            let (index, conversationStatus) = arg
            assertThat(sut, hasViewConfiguredFor: conversationStatus, at: index, file: file, line: line)
        }
    }

    private func assertThat(_ sut: ConversationStatusViewController, hasViewConfiguredFor conversationStatus: ConversationStatus, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.simulateFeedImageViewVisible(at: index)

        guard let cell = view else {
            return XCTFail("Expected \(ConversationStatusCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        let name = conversationStatus.lastMessageUser ?? conversationStatus.groupName
        XCTAssertEqual(cell.nameText, name, "Expected name text to be \(String(describing: name)) for conversation status  view at index (\(index))", file: file, line: line)

        XCTAssertEqual(cell.messageText, conversationStatus.message, "Expected message text to be \(String(describing: conversationStatus.message)) for conversation status view at index (\(index)", file: file, line: line)

        XCTAssertEqual(cell.initialsText, conversationStatus.initials, "Expected message text to be \(String(describing: conversationStatus.initials)) for conversation status view at index (\(index)", file: file, line: line)

        XCTAssertEqual(cell.timeMessageSent, conversationStatus.lastMessageTimeSent, "Expected time sent text to be \(String(describing: conversationStatus.lastMessageTimeSent)) for conversation status view at index (\(index)", file: file, line: line)
    }
}
private extension ConversationStatusViewController {
    func simulateUserInitiatedConversationStatusLoad() {
        refreshControl?.simulateUserInitiatedPullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl!.isRefreshing
    }

    var loadingStatus: String? {
        return header?.subtitleLabel.text
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

    func simulateFeedImageViewNearlyVisible(at index: Int) {
        let dataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: conversationSatusesSection)

        dataSource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }

    func simulateFeedImageViewInvisible(at index: Int) {
        let view = simulateFeedImageViewVisible(at: index)
        let indexPath = IndexPath(row: index, section: conversationSatusesSection)
        let delegate = tableView.delegate

        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }

    func simulateFeedImageViewNotVisible(at index: Int) {
        simulateFeedImageViewNearlyVisible(at: index)
        
        let dataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: conversationSatusesSection)

        dataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
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

    var isShowingRetryAction: Bool {
        return !profileImageRetry.isHidden
    }

    func simulateRetryAction() {
        profileImageRetry.simulateTap()
    }

    var nameText: String? {
        return nameLabel.text
    }

    var messageText: String? {
        return messageLabel.text
    }

    var initialsText: String? {
        return initialsLabel.text
    }

    var timeMessageSent: String? {
        return dateLabel?.text
    }
}

private extension UIImage {
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

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { (target) in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension ConversationStatus {
    var initials: String? {
        let userGroupName = groupName ?? lastMessageUser

        guard let fullName = userGroupName else { return nil }

        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated
        guard let personNameComponents = formatter.personNameComponents(from: fullName) else {
            return nil
        }

        return formatter.string(from: personNameComponents)
    }

    var lastMessageTimeSent: String? {
        return lastMessageTime?.elapsedInterval
    }
}


//
//  ConversationsTests.swift
//  DEUCEiOSTests
//
//  Created by Jose Alvarez on 8/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework
import DEUCEiOS

class ConversationsTests: XCTestCase {
    func test_ViewController_isFirstViewInNavigationController() {
        let (_, sut) = makeSUT()

        XCTAssertNotNil(sut.parent as? UINavigationController, "Expected Conversation to be wrapped in NavigationController")
    }

    // MARK: - Conversation Loader
    func test_loadConversationAction_requestConversationFromLoader() {
        let (loader, sut) = makeSUT()

        XCTAssertEqual(loader.requestCount, 0, "Expected no loading requests before view is loaded.")

        //forces view to load
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.requestCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedConversationLoad()
        XCTAssertEqual(loader.requestCount, 2, "Expected another loading request once user initiates a reload")

        sut.simulateUserInitiatedConversationLoad()
        XCTAssertEqual(loader.requestCount, 3, "Expected yet another loading request once user initiates another reload")
    }

    func test_loadingConversationIndicator_isVisibleWhileLoadingConversation() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeConversationsLoad()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once load completes")

        sut.simulateUserInitiatedConversationLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator when user initiates conversation reload")

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed with error")
    }

    func test_loadConversationCompletion_rendersSuccessfullyLoadedConversation() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        assertThat(sut: sut, isRendering: [])
        let date = Date()

        let Conversation1 = makeConversation(imageURL: nil, message: "a message", lastMessageUser: "Jose Alvarez", lastMessageTime: date, conversationType: 0, groupName: nil, contentType: 0, createdByName: "Creator")
        let Conversation2 = makeConversation(imageURL: URL(string: "http:a-url.com"), message: nil, lastMessageUser: nil, conversationType: 1, groupName: "Group Class", contentType: 0, createdByName: "Group Creator")

        loader.completeConversationsLoad(at: 0, with: [Conversation1])
        assertThat(sut: sut, isRendering: [Conversation1])

        sut.simulateUserInitiatedConversationLoad()
        loader.completeConversationsLoad(at: 1, with: [Conversation1, Conversation2])
        assertThat(sut: sut, isRendering: [Conversation1, Conversation2])
    }

    func test_loadConversationCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        assertThat(sut: sut, isRendering: [])
        let Conversation1 = makeConversation()

        loader.completeConversationsLoad(at: 0, with: [Conversation1])
        assertThat(sut: sut, isRendering: [Conversation1])

        sut.simulateUserInitiatedConversationLoad()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut: sut, isRendering: [Conversation1])
    }

    func test_profileImageView_loadsImageUrlWhenVisible() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let Conversation1 = makeConversation(imageURL: URL(string: "http:a-url.com"))
        let Conversation2 = makeConversation(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationsLoad(at: 0, with: [Conversation1, Conversation2])
        let Conversation3 = makeConversation()

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [Conversation1.image], "Expected first image URL request once first view becomes visible")

        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [Conversation1.image, Conversation2.image], "Expected second image URL request once second view also becomes visible")

        sut.simulateUserInitiatedConversationLoad()
        loader.completeConversationsLoad(at: 1, with: [Conversation3])
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [Conversation1.image, Conversation2.image], "Expected no new URL requests since previous conversation had no image URL")
    }

    func test_profileImageView_cancelsLoadingWhenNotVisibleAnymore() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let Conversation1 = makeConversation(imageURL: URL(string: "http:a-url.com"))
        let Conversation2 = makeConversation(imageURL: URL(string: "http:another-url.com"))

        loader.completeConversationsLoad(at: 0, with: [Conversation1, Conversation2])

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateFeedImageViewInvisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [Conversation1.image], "Expected first image URL request once first view becomes invisible")

        sut.simulateFeedImageViewInvisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [Conversation1.image, Conversation2.image], "Expected first and second images URL request cancelled after they become invisible")

    }

    func test_profileImageViewLoadingIndicator_isVisibleWhileLoadingImages() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let Conversation1 = makeConversation(imageURL: URL(string: "http:a-url.com"))
        let Conversation2 = makeConversation(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationsLoad(with: [Conversation1, Conversation2])

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

        let Conversation1 = makeConversation(imageURL: URL(string: "http:a-url.com"))
        let Conversation2 = makeConversation(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationsLoad(with: [Conversation1, Conversation2])

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

        let Conversation1 = makeConversation(imageURL: URL(string: "http:a-url.com"))
        let Conversation2 = makeConversation(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationsLoad(with: [Conversation1, Conversation2])

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

        let Conversation1 = makeConversation(imageURL: URL(string: "http:a-url.com"))
        let Conversation2 = makeConversation(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationsLoad(with: [Conversation1, Conversation2])

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

        let Conversation1 = makeConversation(imageURL: URL(string: "http:a-url.com"))
        let Conversation2 = makeConversation(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationsLoad(with: [Conversation1, Conversation2])

        let view1 = sut.simulateFeedImageViewVisible(at: 0)!
        let view2 = sut.simulateFeedImageViewVisible(at: 1)!
        XCTAssertEqual(loader.loadedImageURLs, [Conversation1.image, Conversation2.image], "Expected two image URL request for the two visible views")

        loader.completeImageLoadingWithError(at: 0)
        view1.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [Conversation1.image, Conversation2.image, Conversation1.image], "Expected three image URL request for the two visible views")

        loader.completeImageLoadingWithError(at: 1)
        view2.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [Conversation1.image, Conversation2.image, Conversation1.image, Conversation2.image], "Expected three image URL request for the 4 visible views")
    }

    func test_profileImageView_preloadsImageURLWhenNearVisible() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let Conversation1 = makeConversation(imageURL: URL(string: "http:a-url.com"))
        let Conversation2 = makeConversation(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationsLoad(with: [Conversation1, Conversation2])

        sut.simulateFeedImageViewNearlyVisible(at: 0)
        sut.simulateFeedImageViewNearlyVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [Conversation1.image, Conversation2.image], "Expected two image URL request for the two nearly visible views")
    }

    func test_profileImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        let Conversation1 = makeConversation(imageURL: URL(string: "http:a-url.com"))
        let Conversation2 = makeConversation(imageURL: URL(string: "http:another-url.com"))
        loader.completeConversationsLoad(with: [Conversation1, Conversation2])

        sut.simulateFeedImageViewNotVisible(at: 0)
        sut.simulateFeedImageViewNotVisible(at: 1)

        XCTAssertEqual(loader.cancelledImageURLs, [Conversation1.image, Conversation2.image], "Expected two image URL request cancelled for the two not visible views")
    }

    // MARK: - Conversation Listener
    func test_listenForConversation_beginsListeningForConversation() {
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
        XCTAssertEqual(sut.loadingStatus, "connecting...", "Expected connecting... status while connecting")

        loader.notifyStatusChange(status: .connected)
        XCTAssertNil(sut.loadingStatus, "Expected nil status when connected successfully")

        loader.notifyStatusChange(status: .newMessage(makeConversation()))
        XCTAssertNil(sut.loadingStatus, "Expected nil when a new conversation is received.")

        let error = RealTimeConnectionListener.Error.connection
        loader.notifyStatusChange(status: .failed(error))
        XCTAssertEqual(sut.loadingStatus, "disconnected")

        //receiving a new message after being disconnected is unlikely. Nevertheless, we still want to test.
        loader.notifyStatusChange(status: .newMessage(makeConversation()))
        XCTAssertNil(sut.loadingStatus, "Expected nil when a new conversation is received.")

        let invalidData = RealTimeConnectionListener.Error.invalidData
        loader.notifyStatusChange(status: .failed(invalidData))
        XCTAssertNil(sut.loadingStatus, "Expected nil when a conversation can't be decoded properly.")
    }

    func test_TryAgainView_isVisibleWhenListenerFailsToConnect() {
        let (loader, sut) = makeSUT()

        XCTAssertFalse(sut.isTryAgainViewDisplayed, "Expected 'Try Again' view not present before load starts")

        //forces view to load
        sut.loadViewIfNeeded()

        XCTAssertFalse(sut.isTryAgainViewDisplayed, "Expected 'Try Again' view not present before listener begins listening. No response yet.")

        loader.notifyStatusChange(status: .connected)
        XCTAssertFalse(sut.isTryAgainViewDisplayed, "Expected 'Try Again' view not present when connections is successful.")

        let error = RealTimeConnectionListener.Error.connection
        loader.notifyStatusChange(status: .failed(error))
        XCTAssertTrue(sut.isTryAgainViewDisplayed, "Expected 'Try Again' view present when connection fails.")
    }

    func test_ConversationsListener_attemptsToConnectOnRetryAction() {
        let (loader, sut) = makeSUT()

        //forces view to load
        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.realtimeRequestCount, 1, "Expected listener to be called once only")

        let error = RealTimeConnectionListener.Error.connection
        loader.notifyStatusChange(status: .failed(error))
        XCTAssertTrue(sut.isTryAgainViewDisplayed, "Expected 'Try Again' view present when connection fails.")

        sut.simulateTryAgainActionRequested()

        XCTAssertEqual(loader.realtimeRequestCount, 2, "Expected listener to be called two times")
        XCTAssertFalse(sut.isTryAgainViewDisplayed, "Expected 'Try Again' view not present after user attempts connecting again.")

        loader.notifyStatusChange(status: .connected)
        XCTAssertFalse(sut.isTryAgainViewDisplayed, "Expected 'Try Again' view not present when the connection is successful.")
    }

    // MARK: - New Message Functionality

    func test_ConversationObserver_addsNewConversationToTheTopOfList() {
        let (loader, sut) = makeSUT()

        //forces view to load
        sut.loadViewIfNeeded()
        loader.notifyStatusChange(status: .connected)

        let date = Date()

        let Conversation1 = makeConversation(imageURL: nil, message: "a message", lastMessageUser: "Jose Alvarez", lastMessageTime: date, conversationType: 0, groupName: nil, contentType: 0, createdByName: "Creator")
        let Conversation2 = makeConversation(imageURL: URL(string: "http:a-url.com"), message: nil, lastMessageUser: nil, conversationType: 1, groupName: "Group Class", contentType: 0, createdByName: "Group Creator")
        let Conversation3 = makeConversation(imageURL: URL(string: "http:another-url.com"), message: nil, lastMessageUser: nil, conversationType: 1, groupName: "Other Class", contentType: 0, createdByName: "Other Creator")
        let Conversation4 = makeConversation(imageURL: URL(string: "http:yet-another-url.com"), message: nil, lastMessageUser: nil, conversationType: 1, groupName: "Crazy Class", contentType: 0, createdByName: "Crazy Creator")

        loader.completeConversationsLoad(at: 0, with: [Conversation1])
        assertThat(sut: sut, isRendering: [Conversation1])

        sut.simulateUserInitiatedConversationLoad()
        loader.completeConversationsLoad(at: 1, with: [Conversation1, Conversation2])
        assertThat(sut: sut, isRendering: [Conversation1, Conversation2])

        //first new message received via real time
        loader.notifyStatusChange(status: .newMessage(Conversation3))
        assertThat(sut: sut, isRendering: [ Conversation3, Conversation1, Conversation2])

        //second new  message received via real time
        loader.notifyStatusChange(status: .newMessage(Conversation4))
        assertThat(sut: sut, isRendering: [Conversation4, Conversation3, Conversation1, Conversation2])
    }

    func test_ConversationObserver_movesUpdatedConversationToTheTopOfList() {
        let (loader, sut) = makeSUT()

        //forces view to load
        sut.loadViewIfNeeded()
        loader.notifyStatusChange(status: .connected)

        let date = Date()

        let Conversation1 = makeConversation(imageURL: nil, message: "a message", lastMessageUser: "Jose Alvarez", lastMessageTime: date, conversationType: 0, groupName: nil, contentType: 0, createdByName: "Creator")
        let Conversation2 = makeConversation(imageURL: URL(string: "http:a-url.com"), message: nil, lastMessageUser: nil, conversationType: 1, groupName: "Group Class", contentType: 0, createdByName: "Group Creator")
        let Conversation3 = makeConversation(imageURL: URL(string: "http:another-url.com"), message: nil, lastMessageUser: nil, conversationType: 1, groupName: "Other Class", contentType: 0, createdByName: "Other Creator")
        let Conversation4 = makeConversation(imageURL: URL(string: "http:yet-another-url.com"), message: nil, lastMessageUser: nil, conversationType: 1, groupName: "Crazy Class", contentType: 0, createdByName: "Crazy Creator")

        loader.completeConversationsLoad(at: 0, with: [Conversation1, Conversation2, Conversation3, Conversation4])
        assertThat(sut: sut, isRendering: [Conversation1, Conversation2, Conversation3, Conversation4])

        let someTimeLater = Conversation1.lastMessageTime?.addingTimeInterval(1.0)
        let newMessageToSameConversation = Conversation(id: Conversation1.id, image: Conversation1.image, conversationId: Conversation1.conversationId, message: "Different Message", lastMessageUser: Conversation1.lastMessageUser, lastMessageTime: someTimeLater, conversationType: Conversation1.conversationType, groupName: Conversation1.groupName, contentType: Conversation1.contentType, otherUserId: Conversation1.otherUserId, createdByName: Conversation1.createdByName)

        //first new message received via real time
        loader.notifyStatusChange(status: .newMessage(newMessageToSameConversation))
        assertThat(sut: sut, isRendering: [newMessageToSameConversation, Conversation2, Conversation3, Conversation4])
    }


    // MARK: - Helper Methods
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoaderSpy, ConversationsViewController) {
        let loader = LoaderSpy()
        let navigationController = ConversationsComposer.conversationsComposedWith(conversationsLoader: loader, imageDataLoader: loader)
        let sut = navigationController.children.first! as! ConversationsViewController

        trackForMemoryLeaks(object: navigationController, file: file, line: line)
        trackForMemoryLeaks(object: loader, file: file, line: line)
        trackForMemoryLeaks(object: sut, file: file, line: line)

        return (loader, sut)
    }

    private func makeConversation(id: UUID = UUID(), imageURL: URL? = nil, conversationID: UUID = UUID(), message: String? = nil, lastMessageUser: String? = nil, lastMessageTime: Date = Date(), conversationType: Int = 0, groupName: String? = nil, contentType: Int = 0, otherUserId: UUID = UUID(), createdByName: String = "creator") -> Conversation {
        return Conversation(id: id, image: imageURL, conversationId: conversationID, message: message, lastMessageUser: lastMessageUser, lastMessageTime: lastMessageTime, conversationType: conversationType, groupName: groupName, contentType: contentType, otherUserId: otherUserId, createdByName: createdByName)
    }

    private func assertThat(sut: ConversationsViewController, isRendering Conversationes: [Conversation], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedConversationViews(), Conversationes.count, "Expected \(Conversationes.count) conversations, got \(sut.numberOfRenderedConversationViews()) instead.", file: file, line: line)

        Conversationes.enumerated().forEach { (arg) in
            let (index, Conversation) = arg
            assertThat(sut, hasViewConfiguredFor: Conversation, at: index, file: file, line: line)
        }
    }


    /// Tests that the view is configured accordingly
    ///
    /// - Parameters:
    ///   - sut: system under test
    ///   - Conversation: conversation  model
    ///   - index: index
    ///   - file: file in case of failed test (no need to pass anything, it is using default value)
    ///   - line: line number incase of failed test (no need to pass anything, it is using default value)
    private func assertThat(_ sut: ConversationsViewController, hasViewConfiguredFor Conversation: Conversation, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.simulateFeedImageViewVisible(at: index)

        guard let cell = view else {
            return XCTFail("Expected \(ConversationCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        let name = Conversation.lastMessageUser ?? Conversation.groupName
        XCTAssertEqual(cell.nameText, name, "Expected name text to be \(String(describing: name)) for conversation view at index (\(index))", file: file, line: line)

        XCTAssertEqual(cell.messageText, Conversation.message, "Expected message text to be \(String(describing: Conversation.message)) for conversation view at index (\(index)", file: file, line: line)

        XCTAssertEqual(cell.initialsText, Conversation.initials, "Expected message text to be \(String(describing: Conversation.initials)) for conversation view at index (\(index)", file: file, line: line)

        XCTAssertEqual(cell.timeMessageSent, Conversation.lastMessageTimeSent, "Expected time sent text to be \(String(describing: Conversation.lastMessageTimeSent)) for conversation view at index (\(index)", file: file, line: line)
    }
}
private extension ConversationsViewController {
    func simulateUserInitiatedConversationLoad() {
        refreshControl?.simulateUserInitiatedPullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl!.isRefreshing
    }

    var loadingStatus: String? {
        guard let header = navigationItem.titleView as? HeaderView else {
            return nil
        }
        return header.subtitleLabel.text
    }

    var isTryAgainViewDisplayed: Bool {
        if let view = observerController?.retryView {
            return !view.isHidden
        }
        return false
    }

    func simulateTryAgainActionRequested() {
        let view = observerController?.retryView

        view?.simulateTryAgainButtonTapped()
    }

    func numberOfRenderedConversationViews() -> Int {
        return tableView.numberOfRows(inSection: conversationSatusesSection)
    }

    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> ConversationCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: index, section: conversationSatusesSection)

        return dataSource?.tableView(tableView, cellForRowAt: indexPath) as? ConversationCell
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

private extension ConversationCell {
    var isShowingLoadingIndicator: Bool {
        return profileImageView.isShimmering
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

private extension Conversation {
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

private extension TryAgainView {
    func simulateTryAgainButtonTapped() {
        self.onRetryButtonTapped?()
    }
}


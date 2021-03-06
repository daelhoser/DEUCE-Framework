//
//  ConversationsTests+LoaderSpy.swift
//  DEUCEiOSTests
//
//  Created by Jose Alvarez on 8/28/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import XCTest
import DEUCE_Framework
import DEUCEiOS

extension ConversationsTests {
    final class LoaderSpy: ConversationsLoader, ImageDataLoader, RealTimeConnection {
        var requestCount = 0
        private var loadRequests = [(LoadConversationsResult) -> Void]()

        func load(completion: @escaping (LoadConversationsResult) -> Void) {
            requestCount += 1
            loadRequests.append(completion)
        }

        func completeConversationsLoad(at index: Int = 0, with conversations: [Conversation] = [])  {
            loadRequests[index](.success(conversations))
        }

        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            loadRequests[index](.failure(error))
        }

        // MARK - ImageDataLoader

        private struct TaskSpy: ImageDataLoaderTask {
            let cancelCallback: () -> Void

            func cancel() {
                cancelCallback()
            }
        }

        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }


        private var imageRequests = [(url: URL, completion: (Result) -> Void)]()
        private(set) var cancelledImageURLs = [URL]()

        func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataLoaderTask {
            imageRequests.append((url, completion))

            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }

        func completeImageLoading(at index: Int = 0, with data: Data = Data()) {
            let completion = imageRequests[index].completion

            completion(.success(data))
        }

        func completeImageLoadingWithError(at index: Int = 0) {
            let completion = imageRequests[index].completion
            let error = NSError(domain: "Any error", code: 0)
            completion(.failure(error))
        }

        // MARK: - RealTimeConnection
        private(set) var realtimeRequestCount = 0
        private var connectionStatusCompletion: ((ConnectionStatus) -> Void)?

        func start(status: @escaping (ConnectionStatus) -> Void) {
            connectionStatusCompletion = status
            realtimeRequestCount += 1
        }
        
        func stop() {
        }

        func notifyStatusChange(status: ConnectionStatus) {
            connectionStatusCompletion?(status)
        }
    }
}

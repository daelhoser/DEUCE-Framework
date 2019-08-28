//
//  ConversationStatusTests+LoaderSpy.swift
//  DEUCEiOSTests
//
//  Created by Jose Alvarez on 8/28/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation
import XCTest
import DEUCE_Framework
import DEUCEiOS

extension ConversationStatusTests {
    final class LoaderSpy: ConversationStatusLoader, ImageDataLoader {
        var requestCount = 0
        private var loadRequests = [(LoadConversationStatusResult) -> Void]()

        func load(completion: @escaping (LoadConversationStatusResult) -> Void) {
            requestCount += 1
            loadRequests.append(completion)
        }

        func completeConversationStatusLoad(at index: Int = 0, with conversationStatuses: [ConversationStatus] = [])  {
            loadRequests[index](.success(conversationStatuses))
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


        private var imageRequests = [(url: URL, imageLoaderTask: ImageDataLoaderTask, completion: (Result) -> Void)]()
        private(set) var cancelledImageURLs = [URL]()

        func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> ImageDataLoaderTask {
            let loaderTask = TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
            imageRequests.append((url, loaderTask, completion))

            return loaderTask
        }

        func completeImageLoading(at index: Int = 0) {
            let completion = imageRequests[index].completion

            completion(.success(Data()))
        }
    }
}

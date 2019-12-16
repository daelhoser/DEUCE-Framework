//
//  RemoteImageDataLoader.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 12/16/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public final class RemoteImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: ImageDataLoaderTask {
        private var completion: ((ImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (ImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: ImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            case let .success(data, response):
                let isValidResponse = response.statusCode == 200 && !data.isEmpty
                isValidResponse ? task.complete(with: .success(data)) : task.complete(with: .failure(Error.invalidData))
            }
        }
        return task
    }
}

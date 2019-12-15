//
//  URLSessionHTTPClient.swift
//  DEUCE Framework
//
//  Created by Jose Alvarez on 8/19/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient, HTTPClientHeaders {
    private let session: URLSession
    private var headers: [String: String]?

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }

    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) -> HTTPClientTask {
        let request = GETRequest(for: url)

        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
        task.resume()
        
        return URLSessionTaskWrapper(wrapped: task)
    }

    public func addAdditionalHeaders(headers: [String: String]) {
        self.headers = headers
    }

    private func GETRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        if let headers = headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        return request
    }
}

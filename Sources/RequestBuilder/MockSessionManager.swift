//
//  URLMockSessionManager.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/31/22.
//

import Foundation
import Combine

class MockSessionManager: URLSessionManager {

    private var data: Any?
    private let error: Error?
    private let status: Int

    init(data: Data?, status: Int = 200) {
        self.data = data
        self.error = nil
        self.status = status
    }

    init<T>(data: T, status: Int = 200) {
        self.data = data
        self.error = nil
        self.status = status
    }

    init(error: Error) {
        self.data = nil
        self.error = error
        self.status = 999
    }

    func request(forURL url: URL?) -> URLRequestBuilder {
        URLRequestBuilder(manager: self, url: url ?? URL(string: "/"))
    }

    func data(for request: URLRequest) -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
        if let data = data {
            let url = request.url ?? URL(string: "/")!
            return Just((data, HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Just<(Any?, HTTPURLResponse?)>((nil, nil))
            .setFailureType(to: Error.self)
            .tryMap { _ in throw self.error ?? URLError(.badServerResponse) }
            .eraseToAnyPublisher()
    }

}

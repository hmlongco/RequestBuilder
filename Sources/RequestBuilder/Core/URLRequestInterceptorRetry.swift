//
//  URLRequestInterceptorRetry.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/31/22.
//

import Foundation
import Combine

public class URLRequestInterceptorRetry: URLRequestInterceptor {

    public var count: Int
    public var parent: URLSessionManager!

    public init(_ count: Int = 1) {
        self.count = count
    }

    public func data(for request: URLRequest) -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
        return parent.data(for: request)
            .retry(count)
            .eraseToAnyPublisher()
    }
    
}

//
//  URLSessionManager.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/22.
//

import Foundation
import Combine

public protocol URLSessionManager: AnyObject, Sendable {

    // base
    var base: URL? { get }

    // codable
    var encoder: DataEncoder { get }
    var decoder: DataDecoder { get }

    // request support
    func request(forURL url: URL?) -> URLRequestBuilder
    func data(for request: URLRequest) async throws -> (Any?, HTTPURLResponse?)

    // interceptor support
    func interceptor(_ interceptor: URLRequestInterceptor) -> URLSessionManager
    
}

extension URLSessionManager {

    /// Convenience function returns a new request builder using the session's base URL.
    public func request() -> URLRequestBuilder {
        self.request(forURL: nil)
    }

    /// Adds a new intercept handler to the session manager chain
    public func interceptor(_ interceptor: URLRequestInterceptor) -> URLSessionManager {
        interceptor.parent = self
        return interceptor
    }

}

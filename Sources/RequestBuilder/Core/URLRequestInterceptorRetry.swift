//
//  URLRequestInterceptorRetry.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/31/22.
//

import Foundation
import Combine

public final class URLRequestInterceptorRetry: URLRequestInterceptor, @unchecked Sendable {

    public var count: Int
    public var parent: URLSessionManager!

    private var counter: Int = 0

    public init(_ count: Int = 1) {
        self.count = count
    }

    public func data(for request: URLRequest) async throws -> (Any?, HTTPURLResponse?) {
        do {
            return try await parent.data(for: request)
        } catch {
            var counter: Int = count
            while counter > 0 {
                do {
                    return try await parent.data(for: request)
                } catch {
                    counter -= 1
                }
            }
            throw error
        }
    }
}

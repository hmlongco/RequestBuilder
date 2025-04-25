//
//  URLRequestInterceptorStatus.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/31/22.
//

import Foundation
import Combine

public final class URLRequestInterceptorStatusCodes: URLRequestInterceptor, @unchecked Sendable {

    public var parent: URLSessionManager!

    public init() {}

    public func data(for request: URLRequest) async throws -> (Any?, HTTPURLResponse?) {
        let (data, response) = try await parent.data(for: request)
        guard let response, 200..<299 ~= response.statusCode else {
            throw URLError(.badServerResponse)
        }
        return (data, response)
    }

}

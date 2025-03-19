//
//  CallbackTest.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/11/25.
//

import Foundation

struct NewSessionManager {
    var base: URL?
    var session: URLSession
    var decoder: JSONDecoder
}

extension NewSessionManager: CallbackChain {
    var builder: NewRequestBuilder {
        fatalError(#function)
    }
    var data: (NewRequestBuilder, @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void {
        { (builder, callback) in
            session.dataTask(with: builder.request) { (data, response, error) in
                callback(data, response, error)
            }
            .resume()
        }
    }
}

struct NewRequestBuilder {
    var url: URL?
    var request: URLRequest
}

protocol CallbackChain {
    var builder: NewRequestBuilder { get }
    var data: (NewRequestBuilder, @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void { get }
}

protocol CallbackInterceptor {
    var parent: CallbackChain { get }
}

extension CallbackInterceptor {
    var builder: NewRequestBuilder {
        parent.builder
    }
    var data: (NewRequestBuilder, @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> Void {
        parent.data
    }
}

enum CallbackError: Error {
    case bad
}

extension CallbackChain {
    func data() async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation() { continuation in
            data(builder) { (data, response, error) in
                if let data, let response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: error ?? CallbackError.bad)
                }
            }
        }
    }
}

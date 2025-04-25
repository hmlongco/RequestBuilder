//
//  URLSessionManager.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/22.
//

import Foundation
import Combine

public final class BaseSessionManager: URLSessionManager, @unchecked Sendable {

    public var base: URL?
    public var session: URLSession

    public lazy var encoder: DataEncoder = JSONEncoder()
    public lazy var decoder: DataDecoder = JSONDecoder()

    public var parent: URLSessionManager!

    /// Initializes session manager with base URL and configured URLSession.
    public init(base url: URL?, session: URLSession) {
        self.session = session
        self.base = url
    }

    public func set(encoder: DataEncoder) -> Self {
        self.encoder = encoder
        return self
    }

    public func set(decoder: DataDecoder) -> Self {
        self.decoder = decoder
        return self
    }

    /// Returns a builder for construction using URL provided.
    public func request(forURL url: URL?) -> URLRequestBuilder {
        URLRequestBuilder(manager: self, url: url ?? self.base)
    }

    /// Returns requested data and response from session.
    public func data(for request: URLRequest) async throws -> (Data?, HTTPURLResponse?) {
        let (data, response) = try await session.data(for: request)
        return (data, response as? HTTPURLResponse)
    }

}

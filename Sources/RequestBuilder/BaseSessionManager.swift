//
//  URLSessionManager.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/22.
//

import Foundation
import Combine

public class BaseSessionManager: URLSessionManager {

    public var base: URL?
    public var session: URLSession

    public lazy var defaultEncoder: DataEncoder = JSONEncoder()
    public lazy var defaultDecoder: DataDecoder = JSONDecoder()

    public var parent: URLSessionManager!

    /// Initializes session manager with base URL and configured URLSession.
    public init(base url: URL?, session: URLSession) {
        self.session = session
        self.base = url
    }

    public func set(defaultEncoder: DataEncoder) -> Self {
        self.defaultEncoder = defaultEncoder
        return self
    }

    public func set(defaultDecoder: DataDecoder) -> Self {
        self.defaultDecoder = defaultDecoder
        return self
    }

    /// Returns a builder for construction using URL provided.
    public func request(forURL url: URL?) -> URLRequestBuilder {
        URLRequestBuilder(manager: self, url: url ?? self.base)
    }

    /// Returns requested data and response from session.
    public func data(for request: URLRequest) -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
        session.dataTaskPublisher(for: request)
            .map { (data, response) -> (Any?, HTTPURLResponse?) in
                (data, response as? HTTPURLResponse)
            }
            .mapError {
                $0 as Error
            }
            .eraseToAnyPublisher()
    }

}

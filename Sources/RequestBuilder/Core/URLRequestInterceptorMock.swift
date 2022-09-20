//
//  URLRequestInterceptorMock.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/31/22.
//

import Foundation
import Combine

public class URLRequestInterceptorMock: URLRequestInterceptor {

    public static let ANYPATH = "*"

    public typealias Mock = (_ request: URLRequest) throws -> (Any?, Int, [String:String]?)

    public var mocks: [String:Mock] = [:]
    public var parent: URLSessionManager!

    public init() {}

    // MARK: - Path Mocking

    public func add(path: String = ANYPATH, data: Data?, status: Int = 200, headers: [String:String]? = nil) {
        add(path: path) { request in
            (data, status, headers)
        }
    }

    public func add<T:Encodable>(path: String = ANYPATH, data: T, status: Int = 200, headers: [String:String]? = nil) {
        let encoded = try? encoder.encode(data)
        add(path: path) { request in
            (encoded, status, headers)
        }
    }

    public func add(path: String = ANYPATH, data: Any?, status: Int = 200, headers: [String:String]? = nil) {
        add(path: path) { request in
            (data, status, headers)
        }
    }

    public func add(path: String = ANYPATH, json: String, status: Int = 200, headers: [String:String]? = nil) {
        add(path: path) { request in
            (json.data(using: .utf8), status, headers)
        }
     }

    public func add(path: String = ANYPATH, status: Int, headers: [String:String]? = nil) {
        add(path: path) { request in
            (nil, status, headers)
        }
    }

    public func add(path: String = ANYPATH, error: Error) {
        add(path: path) { request in
            throw error
        }
    }

    // MARK: - Supporting

    public func add(path: String, mock: @escaping Mock) {
        if let path = searchPaths(from: path).first {
            mocks[path] = mock
        }
    }

    public func reset() {
        mocks = [:]
    }

    // MARK: - Interceptor

    public func data(for request: URLRequest) -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
        if !mocks.isEmpty {
            for path in searchPaths(from: request.url?.absoluteString) {
                if let mock = mocks[path] {
                    return publisher(for: request, mock: mock)
                }
            }
        }
        return parent.data(for: request)
    }

    // MARK: - Helpers

    public func publisher(for request: URLRequest, mock: Mock) -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
        do {
            guard let url = request.url else {
                throw URLError(.badURL)
            }
            let (data, status, headers) = try mock(request)
            let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: "1.0", headerFields: headers)
            return Just((data, response))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Just<(Any?, HTTPURLResponse?)>((nil, nil))
                .tryMap { _ in throw error }
                .eraseToAnyPublisher()
        }
    }

    // this exists primarily due to randomization of query item elements when absoluteString is built
    // but it also builds a set of paths with and without query parameters.
    public func searchPaths(from path: String?) -> [String] {
        guard var path = path else {
            return [Self.ANYPATH]
        }
        if path == Self.ANYPATH {
            return [Self.ANYPATH]
        }
        if let base = base?.absoluteString, path.hasPrefix(base) {
            path = String(path.dropFirst(base.count))
        }
        let components = path.components(separatedBy: "?")
        if components.count == 1 {
            return [path, Self.ANYPATH]
        }
        let items = components[1]
            .components(separatedBy: "&")
            .sorted()
            .joined(separator: "&")
        // return path with query parameters, path without query parameters, and wildcard path
        return [components[0] + "?" + items, components[0], Self.ANYPATH]
    }

}

extension URLSessionManager {

    /// Allows user to reach into interceptor chain to configure a single mock.
    public var mocks: URLRequestInterceptorMock? {
        find(URLRequestInterceptorMock.self)
    }

    /// Allows user to reach into interceptor chain to configure a set of mocks.
    public func add(configuration: (_ mock: URLRequestInterceptorMock) -> Void) {
        if let interceptor = find(URLRequestInterceptorMock.self) {
            configuration(interceptor)
        }
    }

}

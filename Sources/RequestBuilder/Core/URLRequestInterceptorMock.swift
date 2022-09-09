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

    public struct Mock {
        var status: Int
        var data: () -> Any?
        var error: Error?
    }

    public var mocks: [String:Mock] = [:]
    public var parent: URLSessionManager!

    public init() {}

    // MARK: - Path Mocking

    public func add(data: Data?, status: Int = 200) {
        add(.init(status: status, data: { data }, error: nil))
    }

    public func add(path: String, data: Data?, status: Int = 200) {
        add(.init(status: status, data: { data }, error: nil), path: path)
    }

    public func add<T>(data: @escaping @autoclosure () -> T, status: Int = 200) {
        add(.init(status: status, data: data, error: nil))
    }

    public func add<T>(path: String, data: @escaping @autoclosure () -> T, status: Int = 200) {
        add(.init(status: status, data: data, error: nil), path: path)
    }

    public func add(error: Error, status: Int = 999) {
        add(.init(status: status, data: { nil }, error: error))
    }

    public func add(path: String, error: Error, status: Int = 999) {
        add(.init(status: status, data: { nil }, error: error), path: path)
    }

    public func add(json: String, status: Int = 200) {
        add(.init(status: status, data: {  json.data(using: .utf8) }, error: nil))
    }

    public func add(path: String, json: String, status: Int = 200) {
        add(.init(status: status, data: { json.data(using: .utf8) }, error: nil), path: path)
    }

    public func add(status: Int) {
        add(.init(status: status, data: { Data() }, error: nil))
    }

    public func add(path: String, status: Int) {
        add(.init(status: status, data: { Data() }, error: nil), path: path)
    }

    // MARK: - Supporting

    public func add(_ mock: Mock, path: String = ANYPATH) {
        if let path = searchPaths(from: path).first {
            mocks[path] = mock
       }
    }

    public func reset() {
        mocks = [:]
    }

    // MARK: - Interceptor

    public func data(for request: URLRequest) -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
#if DEBUG
        if !mocks.isEmpty {
            for path in searchPaths(from: request.url?.absoluteString) {
                if let mock = mocks[path] {
                    return publisher(for: mock, path: path)
                }
            }
        }
#endif
        return parent.data(for: request)
    }

    // MARK: - Helpers

    // standard return function for mock
    public func publisher(for mock: Mock, path: String) -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
        if let data = mock.data() {
            return Just((data, HTTPURLResponse(url: URL(string: path)!, statusCode: mock.status, httpVersion: nil, headerFields: nil)))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Just<(Any?, HTTPURLResponse?)>((nil, nil))
                .setFailureType(to: Error.self)
                .tryMap { _ in
                    throw (mock.error ?? URLError(.unknown))
                }
                .eraseToAnyPublisher()
        }
    }

    // this exists due to randomization of query item elements when absoluteString builds
    public func searchPaths(from path: String?) -> [String] {
        guard var path = path else {
            return [Self.ANYPATH]
        }
        if let base = base?.absoluteString, path.hasPrefix(base) {
            path = String(path.dropFirst(base.count))
        }
        let comp = path.components(separatedBy: "?")
        if comp.count == 1 {
            return [path, Self.ANYPATH]
        }
        let items = comp[1]
            .components(separatedBy: "&")
            .sorted()
            .joined(separator: "&")
        return [comp[0] + "?" + items, comp[0], Self.ANYPATH]
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

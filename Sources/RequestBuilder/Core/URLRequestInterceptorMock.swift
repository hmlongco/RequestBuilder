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
        let data: Any?
        let status: Int
        let headers: [String : String]?
        let error: Error?
    }

    public var mocks: [String:Mock] = [:]
    public var parent: URLSessionManager!

    public init() {}

    // MARK: - Path Mocking

    public func add(path: String = ANYPATH, data: Any?, status: Int = 200, headers: [String:String]? = nil) {
        add(path: path, mock: .init(data: data, status: status, headers: headers, error: nil))
    }

    public func add(path: String = ANYPATH, json: String, status: Int = 200, headers: [String:String]? = nil) {
        add(path: path, mock: .init(data: json.data(using: .utf8), status: status, headers: headers, error: nil))
    }

    public func add(path: String = ANYPATH, status: Int, headers: [String:String]? = nil) {
        add(path: path, mock: .init(data: Data(), status: status, headers: headers, error: nil))
    }

    public func add(path: String = ANYPATH, error: Error) {
        add(path: path, mock: .init(data: nil, status: 999, headers: nil, error: error))
    }

    // MARK: - Supporting

    public func add(path: String, mock: Mock) {
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
                    return publisher(for: mock, path: path)
                }
            }
        }
        return parent.data(for: request)
    }

    // MARK: - Helpers

    // standard return function for mock
    public func publisher(for mock: Mock, path: String) -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
        // forced errors override anything else...
        if let error = mock.error {
            return Just<(Any?, HTTPURLResponse?)>((nil, nil))
                .tryMap { _ in
                    throw error
                }
                .eraseToAnyPublisher()
        }
        // otherwise return optional data and status
        return Just((mock.data, HTTPURLResponse(url: URL(string: path)!, statusCode: mock.status, httpVersion: nil, headerFields: mock.headers)))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    // this exists due to randomization of query item elements when absoluteString builds
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

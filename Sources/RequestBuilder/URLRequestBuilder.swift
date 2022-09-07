//
//  URLRequestBuilder.swift
//

import Foundation
import Combine

public struct URLRequestBuilder {

    // Supportrf HTTP methods

    public enum HTTPMethod: String {
        case create
        case get
        case post
        case put
        case delete
    }

    // Internals

    public let manager: URLSessionManager
    public var request: URLRequest!
    
    // lifecycle

    public init(manager: URLSessionManager, url: URL? = nil) {
        self.manager = manager
        self.request = URLRequest(url: url ?? URL(string: "/")!)
    }

    public init(manager: URLSessionManager, builder: URLRequestBuilder) {
        self.manager = manager
        self.request = builder.request
    }

    // Request builder functions

    /// Adds a URL component path to request.
    @discardableResult
    public func add(path: String) -> Self {
        map { $0.request.url?.appendPathComponent(path) }
    }

    /// Adds the following headers to request.
    @discardableResult
    public func add(headers: [String:String]) -> Self {
        map {
            let allHTTPHeaderFields = $0.request.allHTTPHeaderFields ?? [:]
            $0.request.allHTTPHeaderFields = headers.merging(allHTTPHeaderFields, uniquingKeysWith: { $1 })
        }
    }

    /// Adds the following URL parameters to request URL.
    @discardableResult
    public func add(parameters: [String:Any?]) -> Self {
        map {
            if let url = request.url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1 == nil ? "" : "\($1!)" ) }
                $0.request.url = components.url
            }
        }
    }

    /// Adds the following URLQueryItem to request URL.
    @discardableResult
    public func add(queryItems: [URLQueryItem]) -> Self {
        map {
            if let url = request.url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                components.queryItems = (components.queryItems ?? []) + queryItems
                $0.request.url = components.url
            }
        }
    }
    
    /// Adds the dictionary key/values as query items to request URL.
    @discardableResult
    public func add(queryItems: [String:String?]) -> Self {
        add(queryItems: queryItems.map { URLQueryItem(name: $0, value: $1) })
    }

    /// Adds a header value to the request.
    @discardableResult
    public func add(value: String, forHeader field: String) -> Self {
        map { $0.request.addValue(value, forHTTPHeaderField: field) }
    }

    /// Sets the HTTP method for the request.
    @discardableResult
    public func method(_ method: HTTPMethod) -> Self {
        map { $0.request.httpMethod = method.rawValue }
    }

    /// Sets request body to the passed data.
    @discardableResult
    public func body(data: Data?) -> Self {
        map {
            $0.request.httpBody = data
            $0.request.httpMethod = HTTPMethod.post.rawValue
        }
    }

    /// Given an encodable data type, sets the request body to the encoded data.
    @discardableResult
    public func body<DataType:Encodable>(encode data: DataType, encoder: DataEncoder? = nil) -> Self {
        let encoder = encoder ?? manager.defaultEncoder
        return map {
            $0.add(value:"application/json", forHeader: "Content-Type")
            $0.request.httpBody = try? encoder.encode(data)
        }
    }

    /// Given a dictionary, builds the request body as x-www-form-urlencoded data.
    @discardableResult
    public func body(fields: [String:String?]) -> Self {
        map {
            var components = URLComponents()
            components.queryItems = fields.map { URLQueryItem(name: $0, value: $1 == nil ? "" : $1! ) }
            let escapedString = components.percentEncodedQuery?.replacingOccurrences(of: "%20", with: "+")
            $0.add(value:"application/x-www-form-urlencoded", forHeader: "Content-Type")
            $0.request.httpBody = escapedString?.data(using: .utf8)
        }
    }
    
    /// General purpose manipulation function that allows direct access to the URLRequest.
    @discardableResult
    public func with(handler: (_ request: inout URLRequest) -> Void) -> Self {
        var mutable = self
        handler(&mutable.request)
        return mutable
    }

    // helpers
    
    public func map(_ transform: (inout Self) -> ()) -> Self {
        var request = self
        transform(&request)
        return request
    }

}

extension URLRequestBuilder {

    /// Raw data feed from session manager
    public func dataResponse() -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
        manager.data(for: request)
    }

    /// Fetches requested data from the session manager.
    public func data() -> AnyPublisher<Data, Error> {
        manager.data(for: request)
            .tryMap { (data, response) -> Data in
                if let data = data as? Data {
                    return data
                }
                throw URLError(.cannotDecodeContentData)
            }
            .eraseToAnyPublisher()
    }

    /// Fetches requested data from the session manager and decodes it into the provided type.
    public func data<T:Decodable>(type: T.Type, decoder: DataDecoder? = nil) -> AnyPublisher<T, Error> {
        let decoder = decoder ?? manager.defaultDecoder
        return manager.data(for: request)
            .tryMap { (data, response) -> T in
                if let data = data as? Data {
                    do {
                        return try decoder.decode(type, from: data)
                    } catch {
                        throw error
                    }
                } else if let data = data as? T {
                    return data // this supports mocking of types without requiring the type to be Encodable
                }
                throw URLError(.cannotDecodeContentData)
            }
            .eraseToAnyPublisher()
    }

}

public protocol DataEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

extension JSONEncoder: DataEncoder {}
extension PropertyListEncoder: DataEncoder {}

public protocol DataDecoder {
    func decode<Item: Decodable>(_ type: Item.Type, from data: Data) throws -> Item
}

extension JSONDecoder: DataDecoder {}
extension PropertyListDecoder: DataDecoder {}

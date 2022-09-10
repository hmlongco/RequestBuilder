//
//  URLMocking.swift
//  
//
//  Created by Michael Long on 9/10/22.
//

import Foundation

public typealias MockURLResponse = (_ request: URLRequest) throws -> (Any?, HTTPURLResponse?)

public protocol URLMocking {
    func add(path: String, response: @escaping MockURLResponse)
    func reset()
}

extension URLMocking {

    public func add(path: String = "*", data: Any?, status: Int = 200, headers: [String:String]? = nil) {
        add(path: path) { request in
            (data, HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "1.0", headerFields: headers))
        }
    }

    public func add<T:Encodable>(path: String = "*", data: T, status: Int = 200, headers: [String:String]? = nil) {
        let data = try? JSONEncoder().encode(data)
        add(path: path) { request in
            (data, HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "1.0", headerFields: headers))
        }
    }

    public func add(path: String = "*", json: String, status: Int = 200, headers: [String:String]? = nil) {
        add(path: path) { request in
            (json.data(using: .utf8), HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "1.0", headerFields: headers))
        }
    }

    public func add(path: String = "*", status: Int, headers: [String:String]? = nil) {
        add(path: path) { request in
            (nil, HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "1.0", headerFields: headers))
        }
    }

    public func add(path: String = "*", error: Error) {
        add(path: path) { request in
            throw error
        }
    }

}

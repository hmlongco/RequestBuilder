//
//  URLRequestInterceptorLogging.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/31/22.
//

import Foundation
import Combine

public class URLRequestInterceptorLogging: URLRequestInterceptor {
    
     public enum Mode {
        case none
        case debug
        case verbose
    }

    public var mode: Mode
    public var parent: URLSessionManager!

    public init(mode: Mode = .debug) {
        self.mode = mode
    }

    public func data(for request: URLRequest) async throws -> (Any?, HTTPURLResponse?) {
        #if DEBUG
        if mode != .none {
            let path = request.url?.absoluteString ?? "unknown"
            print("REQ: \(path)")
            do {
                let (data, response) = try await parent.data(for: request)
                let status = response?.statusCode ?? 999
                print("\(status): \(path)")
                return (data, response)
            } catch {
                print("ERR: \(path) - \(error.localizedDescription)")
                throw error
            }
        } else {
            return try await parent.data(for: request)
        }
        #else
        try await parent.data(for: request)
        #endif
    }

}

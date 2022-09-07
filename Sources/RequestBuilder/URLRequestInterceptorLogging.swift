//
//  URLRequestInterceptorLogging.swift
//  LiveFrontDemo
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

    public func data(for request: URLRequest) -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
    #if DEBUG
        let logging = mode != .none
        let path = request.url?.absoluteString ?? "unknown"
        return parent.data(for: request)
            .handleEvents { _ in
                if logging {
                    print("REQ: \(path)")
                }
            } receiveOutput: { (data, response) in
                if logging {
                    let status = response?.statusCode ?? 999
                    print("\(status): \(path)")
                }
            } receiveCompletion: { completion in
                if logging {
                    switch completion {
                    case .failure(let error):
                        print("ERR: \(path) - \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                }
            }
            .eraseToAnyPublisher()
    #else
        return parent.data(for: request)
    #endif
    }
    
}

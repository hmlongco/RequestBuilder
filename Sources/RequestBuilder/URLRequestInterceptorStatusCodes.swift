//
//  URLRequestInterceptorStatus.swift
//  LiveFrontDemo
//
//  Created by Michael Long on 8/31/22.
//

import Foundation
import Combine

public class URLRequestInterceptorStatusCodes: URLRequestInterceptor {

    public var parent: URLSessionManager!

     public func data(for request: URLRequest) -> AnyPublisher<(Any?, HTTPURLResponse?), Error> {
        return parent.data(for: request)
             .tryMap({ (data, response) in
                 guard let response, 200..<299 ~= response.statusCode else {
                     throw URLError(.badServerResponse)
                 }
                 return (data, response)
             })
            .eraseToAnyPublisher()
    }
    
}

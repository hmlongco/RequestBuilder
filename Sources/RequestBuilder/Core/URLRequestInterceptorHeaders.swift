//
//  URLRequestInterceptorHeaders.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/31/22.
//

import Foundation
import Combine

public class URLRequestInterceptorHeaders: URLRequestInterceptor {

    public var headers: [String : String]
    public var parent: URLSessionManager!

    public init(_ headers: [String : String]) {
        self.headers = headers
    }

    public func add(_ value: String, forHeader header: String) {
        self.headers[header] = value
    }

    public func remove(_ header: String) {
        self.headers.removeValue(forKey: header)
    }

    public func request(forURL url: URL?) -> URLRequestBuilder {
        URLRequestBuilder(manager: self, builder: parent.request(forURL: url))
            .add(headers: headers)
    }
    
}

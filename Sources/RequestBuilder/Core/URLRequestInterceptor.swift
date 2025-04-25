//
//  URLRequestInterceptor.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/31/22.
//

import Foundation
import Combine

public protocol URLRequestInterceptor: URLSessionManager {

    var parent: URLSessionManager! { get set }

}

extension URLRequestInterceptor {

    ///  Default handler returns base from parent in interceptor chain.
    public var base: URL? {
        parent.base
    }

    ///  Default handler returns encoder from parent in interceptor chain.
    public var encoder: DataEncoder {
        parent.encoder
    }

    ///  Default handler returns decoder from parent in interceptor chain.
    public var decoder: DataDecoder {
        parent.decoder
    }

    /// Default handler returns request from parent in interceptor chain.
    public func request(forURL url: URL?) -> URLRequestBuilder {
        URLRequestBuilder(manager: self, builder: parent.request(forURL: url))
    }

    ///  Default handler returns data from parent in interceptor chain.
    public func data(for request: URLRequest) async throws -> (Data?, HTTPURLResponse?) {
        try await parent.data(for: request)
    }

}

extension URLSessionManager {

    /// Allows user to reach into interceptor chain to configure a specific interceptor.
    public func configure<I:URLRequestInterceptor>(_ type: I.Type, configuration: (_ interceptor: I) -> Void) {
        if let interceptor = find(type) {
            configuration(interceptor)
        }
    }

    /// Allows user to reach into interceptor chain to find a specific interceptor.
    public func find<I:URLRequestInterceptor>(_ type: I.Type) -> I? {
        guard let interceptor = self as? URLRequestInterceptor else {
            return nil
        }
        if let matchingInterceptor = interceptor as? I {
            return matchingInterceptor
        } else {
            return interceptor.parent?.find(type)
        }
    }

}

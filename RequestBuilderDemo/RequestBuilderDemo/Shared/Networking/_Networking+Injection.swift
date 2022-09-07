//
//  _Networking+Injection.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/22.
//

import Foundation
import Factory
import RequestBuilder

extension Container {

    static let sessionManager = Factory<URLSessionManager>(scope: .singleton) {
        BaseSessionManager(base: URL(string: "https://randomuser.me/api"), session: urlSession())
        #if DEBUG
            .interceptor(URLRequestInterceptorMock())
            .interceptor(URLRequestInterceptorLogging(mode: .debug))
        #endif
            .interceptor(URLRequestInterceptorStatusCodes())
            .interceptor(URLRequestInterceptorHeaders([
                "User-Agent": "App(com.example; iOS 15.0.0) Swift 5.5",
                "APP_VERSION": "1.16.0",
                "APP_BUILD_NUM": "450",
                "OS": "iOS",
                "DEVICE_UUID": "a604e727-e7c6-4634-94eb-5c562f14a5da"
            ]))
    }

    private static let urlSession = Factory<URLSession>(scope: .singleton) {
        return URLSession(configuration: URLSessionConfiguration.ephemeral)
    }

}

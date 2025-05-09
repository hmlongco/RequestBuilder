//
//  _Networking+Injection.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/22.
//

import Foundation
import FactoryKit
import RequestBuilder

extension Container {

    public var sessionManager: Factory<URLSessionManager> {
        self {
            BaseSessionManager(base: URL(string: "https://randomuser.me"), session: self.urlSession())
                .set(decoder: JSONDecoder())
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
        .singleton
    }

    public var urlSession: Factory<URLSession> {
        self { URLSession(configuration: URLSessionConfiguration.ephemeral) }.singleton
    }

}

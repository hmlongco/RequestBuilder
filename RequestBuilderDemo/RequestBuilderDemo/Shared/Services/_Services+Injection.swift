//
//  _Services+Injection.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/22.
//

import Foundation
import Factory
import RequestBuilder

extension Container {
    @MainActor
    static let userImageCache = Factory(scope: .shared) {
        UserImageCache()
    }
    static let userServiceType = Factory<UserServiceType> {
        UserService()
    }
}

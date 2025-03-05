//
//  _Services+Injection.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/22.
//

import Foundation
import Factory
import RequestBuilder
import SwiftUI

extension Container {
    
    var userImageCache: Factory<UserImageCache> {
        self {
            UserImageCache(cache: ThrottledAsyncCache(cache: MRUDictionaryCache<URL, UIImage>(), limit: 20))
        }.shared
    }

    @MainActor
    var userServiceType: Factory<UserServiceType> {
        self { @MainActor in UserService() }
    }

}

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

    @MainActor
    var userImageCache: Factory<UserImageCache> {
        self { @MainActor in
            UserImageCache(cache: MRUDictionaryCacheStrategy<URL, UIImage>())
        }.shared
    }

    var userServiceType: Factory<UserServiceType> {
        self { UserService() }
    }

}

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
        self { UserImageCache(cache: MRUDictionaryCacheStrategy<URL, UIImage>()) }.shared
    }

    var userServiceType: Factory<UserServiceType> {
        self { UserService() }
    }

}

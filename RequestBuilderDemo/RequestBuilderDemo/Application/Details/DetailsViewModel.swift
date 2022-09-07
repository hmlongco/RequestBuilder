//
//  DetailsViewModel.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import UIKit
import Factory
import Combine

class DetailsViewModel: ObservableObject {

    // MARK: - Dependencies

    @Injected(Container.userImageCache) private var cache: UserImageCache

    // MARK: - User Information

    var fullname: String { user.fullname }

    var street: String? {
        guard let loc = user.location, let number = loc.street?.number, let name = loc.street?.name else { return "Unlisted" }
        return "\(number) \(name)"
    }

    var showCityStateZip: Bool {
        return cityStateZip != nil
    }

    var cityStateZip: String? {
        guard let loc = user.location, let city = loc.city, let state = loc.state, let zip = loc.postcode else { return nil }
        return "\(city) \(state) \(zip)"
    }

    var showContactBlock: Bool {
        user.email != nil || user.phone != nil
    }

    var email: String? { user.email }
    var phone: String? { user.phone }

    var showAgeBlock: Bool {
        user.dob?.age != nil
    }

    var age: String? {
        guard let age = user.dob?.age else { return nil }
        return "\(age)"
    }

    // MARK: - Internal Variables

    private let user: User

    // MARK: - Lifecycle

    init(user: User) {
        self.user = user
    }

    // MARK: - Custom Publishers

    func photo() -> AnyPublisher<UIImage?, Never> {
        cache.photo(forUser: user)
            .filter { $0 != nil }
            .share()
            .eraseToAnyPublisher()
    }

}

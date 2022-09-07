//
//  UserService.swift
//  LiveFrontDemo
//
//  Created by Michael Long on 8/30/22.
//

import UIKit
import Factory
import Combine
import RequestBuilder

public protocol UserServiceType {
    func list() -> AnyPublisher<[User], APIError>
}

struct UserService: UserServiceType {

    @Injected(Container.sessionManager) private var session

    /// Fetches list of users from API
    public func list() -> AnyPublisher<[User], APIError> {
        return session.request()
            .add(queryItems: ["results" : "50", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self, decoder: JSONDecoder())
            .map(\.results)
            .mapAPIErrors()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

}

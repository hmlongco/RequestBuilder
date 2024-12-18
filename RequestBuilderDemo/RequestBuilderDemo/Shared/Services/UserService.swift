//
//  UserService.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import UIKit
import Factory
import Combine
import RequestBuilder

public protocol UserServiceType {
    func list() -> AnyPublisher<[User], APIError>
    func list() async throws -> [User]
}

struct UserService: UserServiceType {

    @Injected(Container.sessionManager) private var session

    /// Fetches list of users from API and returns result using Combine publisher
    public func list() -> AnyPublisher<[User], APIError> {
        return session.request()
            .add(path: "/api")
            .add(queryItems: ["results" : "50", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self, decoder: JSONDecoder())
            .map(\.results)
            .mapAPIErrors()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Fetches list of users from API and returns result using async/await
    public func list() async throws -> [User] {
        try await session.request()
            .add(path: "/api")
            .add(queryItems: ["results" : "50", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self, decoder: JSONDecoder())
            .results
    }

}

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

public protocol UserServiceType: Sendable {
    func list() async throws -> [User]
}

@MainActor
struct UserService: UserServiceType {

    @Injected(\.sessionManager) private var session

    /// Fetches list of users from API and returns result using async/await
    public func list() async throws -> [User] {
        try await session.request()
            .add(path: "/api")
            .add(queryItems: ["results" : "75", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self, decoder: JSONDecoder())
            .results
    }

}

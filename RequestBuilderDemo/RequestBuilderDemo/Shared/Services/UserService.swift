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
            .add(queryItems: ["results" : "25", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self)
            .results
    }

}

#if DEBUG
extension UserService {

    static func mockNetworkUsers(users: [User] = User.mockUsers) {
        let session = Container.shared.sessionManager()
        let image = UIImage(named: "User-JQ")?.pngData()
        session.mocks?
            .add(path: "User-JQ", data: image)
            .add(path: "/api/portraits/med/men/16.jpg", data: image)
            .add(path: "/api/portraits/men/16.jpg", data: image)
            .add(path: "/api", data: UserResultType(results: users))
    }

    static func mockNetworkError() {
        let session = Container.shared.sessionManager()
        session.mocks?.add(path: "/api", status: 500)
    }

}
#endif

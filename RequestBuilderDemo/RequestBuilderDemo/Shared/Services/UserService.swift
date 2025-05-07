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
    func load() async throws -> [User]
}

public struct UserService: UserServiceType {

    @Injected(\.sessionManager) private var session

    public func load() async throws -> [User] {
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

public struct MockUserService: UserServiceType {
    public func load() async throws -> [User] {
        User.mockUsers
    }
}


public struct MockUserService2: UserServiceType {
    var users: [User] = User.mockUsers
    public func load() async throws -> [User] {
        users
    }
}

public struct MockUserService3: UserServiceType {
    var response: @Sendable () async throws -> [User] = { User.mockUsers }
    public func load() async throws -> [User] {
        try await response()
    }
}

#endif

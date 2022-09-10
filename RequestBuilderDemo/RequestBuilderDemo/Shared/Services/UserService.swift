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

    init() {
        let image = UIImage(named: "User-JQ")?.pngData()
        session.mocks?.add(path: "User-JQ", data: image)
        session.mocks?.add(path: "/api/portraits/med/men/16.jpg", data: image)
        session.mocks?.add(path: "/api/portraits/men/16.jpg", data: image)
//        session.mocks?.add(path: "/api?results=50&seed=998&nat=us", json: "{ \"results\": [] }")
//        session.mocks?.add(path: "/api", json: "{ \"results\": [] }")
//        session.mocks?.add(path: "/api", data: UserResultType(results: []))
//        session.mocks?.add(path: "/api", data: UserResultType(results: User.users))
//        session.mocks?.add(path: "/api", status: 404)
//        session.mocks?.add(status: 401)
//        session.mocks?.add(error: APIError.connection)

//        session.mocks?.add(path: "/api") { request in
//            if let path = request.url?.absoluteString, path.contains("bad") {
//                throw APIError.unknown
//            } else if let file = Bundle.main.url(forResource: "data", withExtension: "json") {
//                return (try? Data(contentsOf: file), nil)
//            } else {
//                throw APIError.unknown
//            }
//        }

    }

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
        return try await session.request()
            .add(path: "/api")
            .add(queryItems: ["results" : "50", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self, decoder: JSONDecoder())
            .map(\.results)
            .mapAPIErrors()
            .async()
    }

}

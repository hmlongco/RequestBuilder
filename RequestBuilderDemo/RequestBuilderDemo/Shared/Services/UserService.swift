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
}

struct UserService: UserServiceType {

    @Injected(Container.sessionManager) private var session

    init() {
        let image = UIImage(named: "User-JQ")?.pngData()
        session.mocks?.mock(path: "/portraits/med/men/16.jpg", data: image)
        session.mocks?.mock(path: "/portraits/men/16.jpg", data: image)
//        session.mocks?.mock(path: "/", json: "{ \"results\": [] }")
//        session.mocks?.mock(path: "/", data: UserResultType(results: []))
//        session.mocks?.mock(path: "/", status: 404)
    }

    /// Fetches list of users from API
    public func list() -> AnyPublisher<[User], APIError> {
        return session.request()
            .add(path: "/")
            .add(queryItems: ["results" : "50", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self, decoder: JSONDecoder())
            .map(\.results)
            .mapAPIErrors()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

}

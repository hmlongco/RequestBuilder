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
        session.mocks?.add(path: "/portraits/med/men/16.jpg", data: image)
        session.mocks?.add(path: "/portraits/men/16.jpg", data: image)
//        session.mocks?.add(path: "/", json: "{ \"results\": [] }")
//        session.mocks?.add(path: "/", data: UserResultType(results: []))
//        session.mocks?.add(path: "/", status: 404)
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

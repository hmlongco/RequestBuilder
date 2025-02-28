//
//  RequestBuilderDemoMocking.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 9/6/22.
//

import SwiftUI
import Factory

extension RequestBuilderDemoApp {

    func setupMocks() {
        let session = Container.shared.sessionManager()
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

}

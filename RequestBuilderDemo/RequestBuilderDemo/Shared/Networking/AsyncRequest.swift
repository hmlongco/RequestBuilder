//
//  RequestUsers.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 5/6/25.
//

import Foundation
import FactoryKit
import RequestBuilder
import SwiftUI

extension Container {
    var requestUsers: Factory<any AsyncRequest<[User]>> {
        self { RequestUsers() }
    }
    var requestUser: Factory<any AsyncParameterRequest<Int, User>> {
        self { RequestUser() }
    }
}

struct RequestUsers: AsyncRequest {
    @Injected(\.sessionManager) var session
    func callAsFunction() async throws -> [User] {
        try await session.request()
            .add(path: "/api")
            .add(queryItems: ["results" : "25", "seed": "998", "nat": "us"])
            .data(type: UserResultType.self)
            .results
    }
}

struct RequestUser: AsyncParameterRequest {
    @Injected(\.sessionManager) var session
    func callAsFunction(_ id: Int) async throws -> User {
        try await session.request()
            .add(path: "/api")
            .add(queryItems: ["id" : "\(id)"])
            .data(type: UserResultType.self)
            .results
            .first!
    }
}

// closures

typealias RequestClosure<T> = @Sendable () async throws -> T

extension Container {
    var requestUserClosure: Factory<RequestClosure<[User]>> {
        Factory(self) {
            {
                @Injected(\.sessionManager) var session
                return try await session.request()
                    .add(path: "/api")
                    .add(queryItems: ["results" : "25", "seed": "998", "nat": "us"])
                    .data(type: UserResultType.self)
                    .results
            }
        }
    }
}

private let defineRequestUserClosure2: RequestClosure<[User]> = {
    @Injected(\.sessionManager) var session
    return try await session.request()
        .add(path: "/api")
        .add(queryItems: ["results" : "25", "seed": "998", "nat": "us"])
        .data(type: UserResultType.self)
        .results
}

extension Container {
    var requestUserClosure2: Factory<RequestClosure<[User]>> {
        Factory(self) { defineRequestUserClosure2 }
    }
}

// protocols

protocol AsyncRequest<T>: Sendable {
    associatedtype T: Sendable
    func callAsFunction() async throws -> T
}

protocol AsyncParameterRequest<P,T>: Sendable {
    associatedtype P
    associatedtype T: Sendable
    func callAsFunction(_ p: P) async throws -> T
}

protocol AsyncTwoParameterRequest<A,B,T>: Sendable {
    associatedtype A
    associatedtype B
    associatedtype T: Sendable
    func callAsFunction(_ a: A, _ b: B) async throws -> T
}

protocol AsyncVoidRequest {
    func callAsFunction() async throws
}

// mocks

struct MockRequest<T>: AsyncRequest {
    let response: @Sendable () async throws -> T
    init(response: @escaping @Sendable () async throws -> T) {
        self.response = response
    }
    func callAsFunction() async throws -> T {
        try await response()
    }
}

struct MockParameterRequest<P,T>: AsyncParameterRequest {
    let response: @Sendable (P) async throws -> T
    init(response: @escaping @Sendable (P) async throws -> T) {
        self.response = response
    }
    func callAsFunction(_ p: P) async throws -> T {
        try await response(p)
    }
}

struct MockTwoParameterRequest<A,B,T: Decodable>: AsyncTwoParameterRequest {
    let response: @Sendable (A, B) async throws -> T
    init(response: @escaping @Sendable (A, B) async throws -> T) {
        self.response = response
    }
    func callAsFunction(_ a: A, _ b: B) async throws -> T {
        try await response(a, b)
    }
}

struct MockVoidRequest: AsyncVoidRequest {
    let response: () async throws -> Void
    init(response: @escaping () async throws -> Void) {
        self.response = response
    }
    func callAsFunction() async throws {
        try await response()
    }
}

// factory mocks

extension Factory {
    @discardableResult
    func mock<R>(_ response : @escaping @Sendable () async throws -> R) -> EmptyView
        where Factory.T == any AsyncRequest<R> {
        self.register { MockRequest(response: response) }
        return EmptyView()
    }

    @discardableResult
    func mock<P,R>(_ response : @escaping @Sendable (P) async throws -> R) -> EmptyView
        where Factory.T == any AsyncParameterRequest<P,R> {
        self.register { MockParameterRequest(response: response) }
        return EmptyView()
    }
}

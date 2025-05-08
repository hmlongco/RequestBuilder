//
//  SwiftTests.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 5/7/25.
//

import Testing
@testable import RequestBuilderDemo

import Factory
import FactoryTesting

enum Failure: Error {
    case failed
    case message(String)
}

@MainActor
@Test(.container)
func test() async throws {
    // conditions
    Container.shared.requestUsers.mock { [User.mockJQ] }
    // actions
    let viewModel = MainViewModel()
    await viewModel.load()
    // results
    guard case .loaded(let users) = viewModel.state else {
        throw Failure.message("unexpected state")
    }
    #expect(users.count == 1)
}

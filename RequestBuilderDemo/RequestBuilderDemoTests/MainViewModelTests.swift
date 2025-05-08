//
//  MainViewModelTests.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 5/7/25.
//

#if swift(>=6.1)

import Testing
@testable import RequestBuilderDemo

import Factory
import FactoryTesting

enum Failure: Error {
    case failed
    case message(String)
}

@Suite(.container)
struct MainViewModelTests {

    @MainActor
    @Test func testHappyPath() async throws {
        // conditions
        Container.shared.requestUsers.mock { [User.mockTS, User.mockJQ] }
        // actions
        let viewModel = MainViewModel()
        await viewModel.load()
        // results
        guard case .loaded(let users) = viewModel.state else {
            throw Failure.message("unexpected state")
        }
        // check user array for correctly sorted results
        try #require(users.count == 2)
        #expect(users[0].fullname == "Jonny Quest")
        #expect(users[1].fullname == "Tom Swift")
    }

    @Test func testEmpty() async throws {
        // conditions
        Container.shared.requestUsers.mock { [] }
        // actions
        let viewModel = await MainViewModel()
        await viewModel.load()
        // results
        guard case .empty(let message) = await viewModel.state else {
            throw Failure.message("unexpected state")
        }
        #expect(message.contains("No current users found."))
    }

    @Test func testError() async throws {
        // conditions
        Container.shared.requestUsers.mock { throw APIError.connection }
        // actions
        let viewModel = await MainViewModel()
        await viewModel.load()
        // results
        guard case .error(let message) = await viewModel.state else {
            throw Failure.message("unexpected state")
        }
        #expect(message.contains("Please try again later."))
    }
}

#endif

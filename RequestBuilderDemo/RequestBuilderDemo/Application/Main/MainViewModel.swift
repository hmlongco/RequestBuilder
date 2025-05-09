//
//  MainViewModel.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/22.
//

import Foundation
import Combine
import FactoryKit

@MainActor
class MainViewModel: ObservableObject {

    //    @Injected(\.userServiceType) var service: UserServiceType
    @Injected(\.requestUsers) var asyncRequestUsers

    enum State: Equatable {
        case loading
        case loaded([User])
        case empty(String)
        case error(String)
    }

    private var processing = false

    @Published private(set) var state = State.loading {
        didSet {
            print("STATE = \(String(describing: state))")
        }
    }

    deinit {
        print("MainViewModel DEINIT")
    }

    func load() async {
        do {
            let users = try await asyncLoadProcessNonisolated()
            if users.isEmpty {
                state = .empty("No current users found...")
            } else {
                state = .loaded(users)
            }
        } catch is CancellationError {
            state = .error("Cancelled.")
        } catch {
            state = .error(error.localizedDescription + " Please try again later.")
        }
    }

    private nonisolated func asyncLoadProcessNonisolated() async throws -> [User] {
        //        let users = try await service.list()
        let users = try await asyncRequestUsers()
        try Task.checkCancellation() // don't start long running sort if not needed
        return users.sorted { ($0.name.last + $0.name.first).lowercased() < ($1.name.last + $1.name.first).lowercased() }
    }

    func refresh() {
        state = .loading
    }

}

class Tracker {
    let id: String
    init(_ id: String) {
        self.id = id
        print("Tracker \(id) INITIALIZED")
    }
    deinit {
        print("Tracker \(id) RELEASED")
    }
}

//
//  MainViewModel.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/22.
//

import Foundation
import Combine
import Factory

@MainActor
class MainViewModel: ObservableObject {

    @Injected(\.userServiceType) var service: UserServiceType

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

    func asyncLoadFromTask() async {
        state = .loading
        do {
            let users = try await asyncLoadProcessNonisolated()
            if users.isEmpty {
                state = .empty("No current users found...")
            } else {
                state = .loaded(users)
            }
        } catch is CancellationError {
            print("cancelled") // ignore
        } catch {
            state = .error(error.localizedDescription + " Please try again later.")
        }
    }

    private nonisolated func asyncLoadProcessNonisolated() async throws -> [User] {
        let users = try await service.list()
        try Task.checkCancellation()
        return users.sorted { ($0.name.last + $0.name.first).lowercased() < ($1.name.last + $1.name.first).lowercased() }
    }

    func refresh() {
        state = .loading
    }

}

extension MainViewModel {

    @MainActor
    func asyncLoadFromAppear() {
        state = .loading
        Task {
            do {
                let users = try await asyncLoadProcessSubtask()
                if users.isEmpty {
                    state = .empty("No current users found...")
                } else {
                    state = .loaded(users)
                }
            } catch is CancellationError {
                // ignore
            } catch {
                state = .error(error.localizedDescription + " Please try again later.")
            }
        }
    }

    private func asyncLoadProcessSubtask() async throws -> [User] {
        let users = try await service.list()
        try Task.checkCancellation()
        return await Task {
            users.sorted { ($0.name.last + $0.name.first).lowercased() < ($1.name.last + $1.name.first).lowercased() }
        }.value
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


class CommonViewModel: ObservableObject {

    @Published var users: [User] = []

    let userAPI = UserAPI()
    var cancellables = Set<AnyCancellable>()

    func load() {
        userAPI.load()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { users in
                self.users = users
            })
            .store(in: &cancellables)
    }
}

struct UserAPI {
    func load() -> AnyPublisher<[User], Never> {
        Just<[User]>([])
            .eraseToAnyPublisher()
    }
}

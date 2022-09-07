//
//  MainViewModel.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/29/22.
//

import Foundation
import Combine
import Factory

class MainViewModel: ObservableObject {

    @Injected(Container.userServiceType) var service: UserServiceType

    enum State: Equatable {
        case loading
        case loaded([User])
        case empty(String)
        case error(String)
    }

    @Published private(set) var state = State.loading

    private var cancellables = Set<AnyCancellable>()

    func load() {
        state = .loading
        service.list()
            .map {
                $0.sorted(by: { ($0.name.last + $0.name.first).localizedLowercase < ($1.name.last + $1.name.first).localizedLowercase })
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.state = .error(error.localizedDescription + " Please try again later.")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] (users) in
                if users.isEmpty {
                    self?.state = .empty("No current users found...")
                } else {
                    self?.state = .loaded(users)
                }
            })
            .store(in: &cancellables)
    }

    func refresh() {
        state = .loading
    }

}

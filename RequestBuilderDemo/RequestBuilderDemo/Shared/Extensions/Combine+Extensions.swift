//
//  Combine+Extensions.swift
//  RequestBuilder
//
//  Created by Michael Long on 9/1/22.
//

import Foundation
import Combine

extension AnyCancellable {
    convenience init<T,E>(_ task: Task<T,E>) {
        self.init(task.cancel)
    }
}

extension Task {
    func store(in cancellable: inout AnyCancellable?) {
        cancellable = AnyCancellable(self)
    }
    func store(in cancellables: inout Set<AnyCancellable>) {
        cancellables.insert(AnyCancellable(self))
    }
}

extension Publisher {
    func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == Optional<T> {
        compactMap { $0 }
    }
}

extension Subscribers.Completion {
    func error() throws -> Failure {
        if case let .failure(error) = self {
            return error
        }
        throw ErrorFunctionThrowsError.error
    }
    private enum ErrorFunctionThrowsError: Error { case error }
}



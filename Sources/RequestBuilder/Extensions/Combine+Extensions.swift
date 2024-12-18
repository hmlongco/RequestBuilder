//
//  Combine+Extensions.swift
//
//  Added by Michael Long on 9/9/22.
//
//  Based on https://medium.com/geekculture/from-combine-to-async-await-c08bf1d15b77
//  By Eduardo Domene Junior
//

import Foundation
import Combine

extension Publisher {
    public func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(throwing: PublisherAsyncError.finishedWithoutValue)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }
}

public enum PublisherAsyncError: Error {
    case finishedWithoutValue
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

public enum AsyncError: Error {
    case finishedWithoutValue
}

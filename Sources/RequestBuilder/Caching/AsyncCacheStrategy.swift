//
//  AsyncCacheStrategy.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/1/25.
//

import Foundation
import os

public protocol AsyncCacheStrategy<Key, Value>: Sendable {

    associatedtype Key: Hashable & Sendable
    associatedtype Value: Sendable

    func currentItem(for key: Key) -> Value?

    func item(for key: Key, request: @escaping @Sendable () async throws -> Value?) async -> Value?

    func cancel()
    func reset()

}

@globalActor
actor AsyncCacheActor {
    static let shared = AsyncCacheActor()
}

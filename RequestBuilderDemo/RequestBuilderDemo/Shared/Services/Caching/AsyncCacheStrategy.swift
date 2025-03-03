//
//  AsyncCacheStrategy.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/1/25.
//

import Foundation
import os

public protocol AsyncCacheStrategy<Key, Value> {

    associatedtype Key: Hashable & Sendable
    associatedtype Value: Sendable

    @MainActor func currentItem(for key: Key) -> Value?
    @MainActor func item(for key: Key, request: @escaping () async throws -> Value?) async -> Value?

    @MainActor func reset()

}

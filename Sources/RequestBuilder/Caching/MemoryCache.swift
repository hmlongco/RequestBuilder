//
//  MemoryCache.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/2/25.
//

import Foundation
import os

public final class MemoryCache<Key: Hashable & Sendable, Value: Sendable>: CacheStrategy {

    private var cache: OSAllocatedUnfairLock<Dictionary<Key, Value>> = .init(initialState: [:])

    public init() {}

    public func get(_ key: Key) -> Value? {
        cache.withLock { $0[key] }
    }

    public func set(_ key: Key, value: Value) {
        cache.withLock { $0[key] = value }
    }

    public func remove(_ key: Key) {
        cache.withLock { _ = $0.removeValue(forKey: key) }
    }

    public func reset() {
        cache.withLock { $0 = [:] }
    }

}

//
//  CacheStrategy.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/2/25.
//

import Foundation
import os

public protocol CacheStrategy<Key, Value> {

    associatedtype Key: Hashable
    associatedtype Value

    func get(_ key: Key) -> Value?
    func set(_ key: Key, value: Value)

    func reset()

}

public final class BasicCache<Key: Hashable, Value>: CacheStrategy {

    private var cache: OSAllocatedUnfairLock<Dictionary<Key, Value>> = .init(initialState: [:])

    public init() {}

    public func get(_ key: Key) -> Value? {
        cache.withLock { $0[key] }
    }

    public func set(_ key: Key, value: Value) {
        cache.withLock { $0[key] = value }
    }

    public func reset() {
        cache.withLock { $0 = [:] }
    }

}

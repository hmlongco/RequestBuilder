//
//  AsyncCacheStrategy.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/1/25.
//

import Foundation

public protocol AsyncCacheStrategy<Key, Value> {

    associatedtype Key: Hashable
    associatedtype Value

    @MainActor func findEntry(for key: Key) -> AsyncCacheEntry<Key, Value>?
    @MainActor func newEntry(for key: Key, task: Task<Value?, Error>) -> AsyncCacheEntry<Key, Value>

    @MainActor func reset()

}

public class SimpleCacheStrategy<Key: Hashable, Value>: AsyncCacheStrategy {

    private var cache: [Key: AsyncCacheEntry<Key, Value>] = [:]

    public init() {}

    public func findEntry(for key: Key) -> AsyncCacheEntry<Key, Value>? {
        cache[key]
    }

    public func newEntry(for key: Key, task: Task<Value?, Error>) -> AsyncCacheEntry<Key, Value> {
        let entry = AsyncCacheEntry(key: key, task: task)
        cache[key] = entry
        return entry
    }

    public func reset() {
        cache = [:]
    }

}

//
//  AsyncCacheStrategy.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/1/25.
//

import Foundation
import os

public protocol AsyncCacheStrategy<Key, Value> {

    associatedtype Key: Hashable
    associatedtype Value

    @MainActor func currentItem(for key: Key) -> Value?
    @MainActor func item(for key: Key, factory: @escaping () async throws -> Value?) async -> Value?

    func reset()

}

public class AsyncCache<Key: Hashable, Value>: AsyncCacheStrategy {

    private var cache: any CacheStrategy<Key, Value>
    private var tasks: [Key: Task<Value?, Never>] = [:]

    public init(cache: any CacheStrategy<Key, Value>) {
        self.cache = cache
    }

    public func currentItem(for key: Key) -> Value? {
        cache.get(key)
    }

    public func item(for key: Key, factory: @escaping () async throws -> Value?) async -> Value? {
        if let item = cache.get(key) {
            return item
        }

        if let task = tasks[key] {
            return await task.value
        }

        defer { tasks.removeValue(forKey: key) }

        let task = Task<Value?, Never> { try? await factory() }
        tasks[key] = task

        if let value = await task.value {
            cache.set(key, value: value)
            return value
        }

        return nil
    }

    public func reset() {
        cache.reset()
    }

}

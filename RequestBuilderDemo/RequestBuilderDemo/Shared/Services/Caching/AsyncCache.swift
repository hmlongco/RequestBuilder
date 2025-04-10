//
//  AsyncCache.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/2/25.
//

import Foundation
import os

public class AsyncCache<Key: Hashable & Sendable, Value: Sendable>: AsyncCacheStrategy, @unchecked Sendable {

    private var cache: any CacheStrategy<Key, Value>
    private var tasks: [Key: Task<Value?, Never>] = [:]

    public init(cache: any CacheStrategy<Key, Value>) {
        self.cache = cache
    }

    deinit {
        tasks.forEach { $1.cancel() }
    }

    public func currentItem(for key: Key) -> Value? {
        cache.get(key)
    }

    @AsyncCacheActor
    public func item(for key: Key, request: @escaping () async throws -> Value?) async -> Value? {
        if let item = cache.get(key) {
            return item
        }

        if let task = tasks[key] {
            return await task.value
        }

        let task = Task<Value?, Never> { try? await request() }

        defer { tasks.removeValue(forKey: key) }
        tasks[key] = task

        let value = await task.value
        cache.set(key, value: value)

        return value
    }

    public func cancel() {
        tasks.forEach { $1.cancel() }
    }

    public func reset() {
        cache.reset()
    }

}

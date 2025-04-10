//
//  ThrottledAsyncCache.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/2/25.
//

import Foundation

public class ThrottledAsyncCache<Key: Hashable & Sendable, Value: Sendable>: AsyncCacheStrategy, @unchecked Sendable {

    public typealias Request = () async throws -> Value?

    private var cache: any CacheStrategy<Key, Value>
    private var tasks: [Key: Task<Value?, Never>] = [:]

    private let semaphore: AsyncSemaphore

    public init(cache: any CacheStrategy<Key, Value>, limit: Int = 20) {
        self.cache = cache
        self.semaphore = LimitAsyncSemaphore(limit: limit)
    }

    deinit {
        tasks.forEach { $1.cancel() }
    }

    public func currentItem(for key: Key) -> Value? {
        cache.get(key)
    }

    @AsyncCacheActor
    public func item(for key: Key, request: @escaping Request) async -> Value? {
        if let item = cache.get(key) {
            return item
        }

        if let task = tasks[key] {
            return await task.value
        }

        let task = Task<Value?, Never> {
            var value: Value?
            await semaphore.wait()
            if Task.isCancelled == false {
                value = try? await request()
                cache.set(key, value: value)
            }
            tasks.removeValue(forKey: key)
            await semaphore.signal()
            return value
        }

        tasks[key] = task

        return await task.value
    }

    public func cancel() {
        tasks.forEach { $1.cancel() }
    }

    public func reset() {
        cache.reset()
    }

}

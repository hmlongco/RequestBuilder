//
//  ThrottledAsyncCache.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/2/25.
//

import Foundation

public class ThrottledAsyncCache<Key: Hashable & Sendable, Value: Sendable>: AsyncCacheStrategy {

    public typealias Factory = () async throws -> Value?

    private var cache: any CacheStrategy<Key, Value>
    private var tasks: [Key: Task<Value?, Never>] = [:]

    private var queue: [CheckedContinuation<Void, Never>] = []
    private let limit: Int
    private var count = 0

    public init(cache: any CacheStrategy<Key, Value>, limit: Int = 20) {
        self.cache = cache
        self.limit = limit
    }

    deinit {
        tasks.forEach { $1.cancel() }
    }

    @MainActor
    public func currentItem(for key: Key) -> Value? {
        cache.get(key)
    }

    @MainActor
    public func item(for key: Key, request: @escaping Factory) async -> Value? {
        if let item = cache.get(key) {
            return item
        }

        if let task = tasks[key] {
            return await task.value
        }

        // only a limited number of tasks can be active at the same time
        await semaphore()

        // double check needed as duplicate requests could have been made while suspended
        if let item = cache.get(key) {
            signal()
            return item
        }

        if let task = tasks[key] {
            // already have a task, open up our "slot" while we wait on someone else's task
            // defer would wait until after the task returned.
            signal()
            return await task.value
        }

        let task = Task<Value?, Never> { try? await request() }
        tasks[key] = task

        let value = await task.value
        cache.set(key, value: value)

        tasks.removeValue(forKey: key)
        signal()

        return value
    }

    @MainActor
    public func cancel() {
        tasks.forEach { $1.cancel() }
    }

    @MainActor
    public func reset() {
        cache.reset()
    }

    @MainActor
    private func semaphore() async {
        await withCheckedContinuation { continuation in
            if count < limit {
                count += 1
                continuation.resume()
            } else {
                // print("THROTTLED")
                queue.append(continuation)
            }
        }
    }

    @MainActor
    private func signal() {
        if let continuation = queue.first {
            queue.removeFirst()
            continuation.resume()
        } else {
            count = max(count - 1, 0)
        }
    }

}

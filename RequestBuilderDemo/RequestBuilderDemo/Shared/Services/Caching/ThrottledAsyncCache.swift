//
//  ThrottledAsyncCache.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/2/25.
//

import Foundation

public class ThrottledAsyncCache<Key: Hashable & Sendable, Value: Sendable>: AsyncCacheStrategy {

    private var cache: any CacheStrategy<Key, Value>
    private var tasks: [Key: Task<Value?, Never>] = [:]

    private let limit: Int
    private var currentCount = 0
    private var waitQueue: [CheckedContinuation<Void, Never>] = []

    public init(cache: any CacheStrategy<Key, Value>, limit: Int = 20) {
        self.cache = cache
        self.limit = limit
    }

    deinit {
        tasks.forEach { $1.cancel() }
    }

    public func item(for key: Key, request: @escaping () async throws -> Value?) async -> Value? {
        if let item = cache.get(key) {
            return item
        }

        if let task = tasks[key] {
            return await task.value
        }

        defer { signal() }
        await semaphore()

        if Task.isCancelled {
            return nil
        }

        if let item = cache.get(key) {
            return item
        }

        if let task = tasks[key] {
            return await task.value
        }

        let task = Task<Value?, Never> { try? await request() }
        tasks[key] = task

        let value = await task.value
        cache.set(key, value: value)

        tasks.removeValue(forKey: key)

        return value
    }

    @MainActor
    public func currentItem(for key: Key) -> Value? {
        cache.get(key)
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
            if currentCount < limit {
                currentCount += 1
                continuation.resume()
            } else {
                waitQueue.append(continuation)
            }
        }
    }

    @MainActor
    private func signal() {
        if let continuation = waitQueue.first {
            waitQueue.removeFirst()
            continuation.resume()
        } else {
            currentCount = max(currentCount - 1, 0)
        }
    }

}

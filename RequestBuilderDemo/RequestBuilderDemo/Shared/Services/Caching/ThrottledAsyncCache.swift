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

    private let semaphore: AsyncSemaphore

    public init(cache: any CacheStrategy<Key, Value>, limit: Int = 20) {
        self.cache = cache
        self.semaphore = .init(limit: limit)
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

        await semaphore.wait()

        if let item = cache.get(key) {
            await semaphore.signal()
            return item
        }

        if let task = tasks[key] {
            await semaphore.signal() // waiting on someone else's task so unblock while we wait
            return await task.value
        }

        let task = Task<Value?, Never> { try? await request() }
        tasks[key] = task

        let value = await task.value
        cache.set(key, value: value)

        tasks.removeValue(forKey: key)
        await semaphore.signal()

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

}

private actor AsyncSemaphore {

    private let limit: Int
    private var currentCount = 0
    private var waitQueue: [CheckedContinuation<Void, Never>] = []

    init(limit: Int) {
        self.limit = limit
    }

    func wait() async {
        await withCheckedContinuation { continuation in
            if currentCount < limit {
                currentCount += 1
                continuation.resume()
            } else {
                waitQueue.append(continuation)
            }
        }
    }

    func signal() {
        if let continuation = waitQueue.first {
            waitQueue.removeFirst()
            continuation.resume()
        } else {
            currentCount = max(currentCount - 1, 0)
        }
    }

}

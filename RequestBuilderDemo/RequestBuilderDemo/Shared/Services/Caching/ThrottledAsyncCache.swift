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

    public init(cache: any CacheStrategy<Key, Value>, limit: Int = 12) {
        self.cache = cache
        self.semaphore = AsyncSemaphore(limit: limit)
    }

    deinit {
        tasks.forEach { $1.cancel() }
    }

    public func item(for key: Key, request: @escaping () async throws -> Value?) async -> Value? {
        // if existing cached value return it
        if let item = cache.get(key) {
            return item
        }
        // if existing cached task wait for it
        if let task = tasks[key] {
            return await task.value
        }
        // wait our turn
        await semaphore.wait()
        // check for cancellation
        guard Task.isCancelled == false else {
            await semaphore.signal()
            return nil
        }
        // someone else could have snuck in during our await
        if let task = tasks[key] {
            await semaphore.signal() // release, we're waiting on someone else's task
            return await task.value
        }
        // our turn, fire the task and store it
        let task = Task<Value?, Never> { try? await request() }
        tasks[key] = task
        // wait for results
        let value = await task.value
        cache.set(key, value: value)
        // cleanup
        tasks.removeValue(forKey: key)
        await semaphore.signal()
        // done
        return value
    }

    public func currentItem(for key: Key) -> Value? {
        cache.get(key)
    }

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


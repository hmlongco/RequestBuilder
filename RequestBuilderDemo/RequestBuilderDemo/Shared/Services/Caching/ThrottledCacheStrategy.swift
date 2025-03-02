////
////  ThrottledCacheStrategy.swift
////  RequestBuilderDemo
////
////  Created by Michael Long on 3/2/25.
////
//
//import Foundation
//
//public class ThrottledCacheStrategy<Key: Hashable, Value>: AsyncCacheStrategy {
//
//    private var cache: any AsyncCacheStrategy<Key, Value>
//    private let semaphore: AsyncSemaphore
//
//    public init(cache: any AsyncCacheStrategy<Key, Value>, limit: Int = 12) {
//        self.cache = cache
//        self.semaphore = AsyncSemaphore(limit: limit)
//    }
//
//    public func item(for key: Key, factory: @escaping () async throws -> Value?) async -> Value? {
//        // if existing cached task wait for it
//        if let entry = currentEntry(for: key) {
//            if let item = entry.cachedItem() {
//                return item
//            }
//            return await entry.item()
//        }
//        // wait our turn
//        await semaphore.wait()
//        // check for cancellation
//        guard Task.isCancelled == false else {
//            await semaphore.signal()
//            return nil
//        }
//        // someone else could have snuck in during our await
//        if let entry = currentEntry(for: key) {
//            let value = await entry.item()
//            await semaphore.signal()
//            return value
//        }
//        // our turn, fire the task
//        let value = await newEntry(for: key, task: Task { try? await factory() })
//        // done
//        await semaphore.signal()
//        return value
//    }
//
//    public func currentEntry(for key: Key) -> AsyncCacheEntry<Key, Value>? {
//        cache.currentEntry(for: key)
//    }
//
//    public func newEntry(for key: Key, task: Task<Value?, Error>) async -> Value? {
//        await cache.newEntry(for: key, task: task)
//    }
//
//    public func reset() {
//        cache.reset()
//    }
//
//}
//
//private actor AsyncSemaphore {
//
//    private let limit: Int
//    private var currentCount = 0
//    private var waitQueue: [CheckedContinuation<Void, Never>] = []
//
//    init(limit: Int) {
//        self.limit = limit
//    }
//
//    func wait() async {
//        await withCheckedContinuation { continuation in
//            if currentCount < limit {
//                currentCount += 1
//                continuation.resume()
//            } else {
//                waitQueue.append(continuation)
//            }
//        }
//    }
//
//    func signal() {
//        if let continuation = waitQueue.first {
//            waitQueue.removeFirst()
//            continuation.resume()
//        } else {
//            currentCount -= 1
//        }
//    }
//
//}
//

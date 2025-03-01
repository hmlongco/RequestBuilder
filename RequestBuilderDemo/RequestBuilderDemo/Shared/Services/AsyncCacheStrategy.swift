//
//  AsyncCacheStrategy.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/1/25.
//

import Foundation

@MainActor
protocol AsyncCacheStrategy<Key, Value> {

    associatedtype Key: Hashable
    associatedtype Value

    func findEntry(for key: Key) -> AsyncCacheEntry<Key, Value>?
    func newEntry(for key: Key, task: Task<Value?, Error>) -> AsyncCacheEntry<Key, Value>

    func reset()

}

@MainActor
internal class AsyncCacheEntry<Key: Hashable, Value> {

    let key: Key

    private enum State: Error {
        case loading(Task<Value?, Error>)
        case loaded(Value)
        case error
    }

    private var state: State

    init(key: Key, task: Task<Value?, Error>) {
        self.key = key
        self.state = .loading(task)
    }

    func cachedItem() -> Value? {
        if case .loaded(let item) = state {
            return item
        }
        return nil
    }

    func item() async -> Value? {
        switch state {
        case .loading(let task):
            if let item = try? await task.value {
                state = .loaded(item)
                return item
            } else {
                state = .error
                return nil
            }
        case .loaded(let item):
            return item
        case .error:
            return nil
        }
    }

    func cancel() {
        if case let .loading(task) = state {
            task.cancel()
            state = .error
        }
    }

}

class MRUDictionaryCacheStrategy<Key: Hashable, Value>: AsyncCacheStrategy {

    private var cache: [Key: TimestampedCacheEntry<Key, Value>] = [:]
    private var maxSize: Int
    private var dropCount: Int

    init(maxSize: Int = 100, dropPercentage: Int = 10) {
        self.maxSize = max(maxSize, 1)
        self.dropCount = max(maxSize / dropPercentage, 1)
        self.cache.reserveCapacity(maxSize / 2)
    }

    internal func findEntry(for key: Key) -> AsyncCacheEntry<Key, Value>? {
        cache[key]
    }

    internal func newEntry(for key: Key, task: Task<Value?, Error>) -> AsyncCacheEntry<Key, Value> {
        if cache.count == maxSize {
            sweepAndRemoveOldestEntries()
        }
        let entry = TimestampedCacheEntry(key: key, task: task)
        cache[key] = entry
        return entry
    }

    internal func sweepAndRemoveOldestEntries() {
        cache.values
            .sorted { $0.lastReferenced < $1.lastReferenced }
            .prefix(dropCount)
            .forEach { cache.removeValue(forKey: $0.key) }
    }

    internal func reset() {
        cache = [:]
    }

}

internal class TimestampedCacheEntry<Key: Hashable, Value>: AsyncCacheEntry<Key, Value> {
    private(set) var lastReferenced: Date = .now
    override init(key: Key, task: Task<Value?, Error>) {
        super.init(key: key, task: task)
    }
    override func cachedItem() -> Value? {
        lastReferenced = .now
        return super.cachedItem()
    }
    override func item() async -> Value? {
        lastReferenced = .now
        return await super.item()
    }
}

class MRUArrayCacheStrategy<Key: Hashable, Value>: AsyncCacheStrategy {

    private var cache: [AsyncCacheEntry<Key, Value>] = []
    private var maxSize: Int
    private var dropCount: Int

    init(maxSize: Int = 100, dropPercentage: Int = 10) {
        self.maxSize = max(maxSize, 1)
        self.dropCount = max(maxSize / dropPercentage, 1)
        self.cache.reserveCapacity(maxSize / 2)
    }

    internal func findEntry(for key: Key) -> AsyncCacheEntry<Key, Value>? {
        if let index = cache.lastIndex(where: { $0.key == key }) {
            let entry = cache[index]
            if index < cache.count - 1 {
                cache.remove(at: index)
                cache.append(entry)
            }
            return entry
        }
        return nil
    }

    internal func newEntry(for key: Key, task: Task<Value?, Error>) -> AsyncCacheEntry<Key, Value> {
        if cache.count == maxSize {
            cache = Array(cache.dropFirst(dropCount))
        }
        let entry = AsyncCacheEntry(key: key, task: task)
        cache.append(entry)
        return entry
    }

    internal func reset() {
        cache = []
    }

}


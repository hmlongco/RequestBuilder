//
//  MRUDictionaryCacheStrategy.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/1/25.
//

import Foundation

public class MRUDictionaryCacheStrategy<Key: Hashable, Value>: AsyncCacheStrategy {

    private var cache: [Key: TimestampedCacheEntry<Key, Value>] = [:]
    private var maxSize: Int
    private var dropCount: Int

    public init(maxSize: Int = 100, dropPercentage: Int = 10) {
        self.maxSize = max(maxSize, 1)
        self.dropCount = max(maxSize / dropPercentage, 1)
        self.cache.reserveCapacity(maxSize / 2)
    }

    public func findEntry(for key: Key) -> AsyncCacheEntry<Key, Value>? {
        cache[key]
    }

    public func newEntry(for key: Key, task: Task<Value?, Error>) -> AsyncCacheEntry<Key, Value> {
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

    public func reset() {
        cache = [:]
    }

}

internal class TimestampedCacheEntry<Key: Hashable, Value>: AsyncCacheEntry<Key, Value> {

    private(set) var lastReferenced: Date = .now

    override init(key: Key, task: Task<Value?, Error>) {
        super.init(key: key, task: task)
    }

    public override func cachedItem() -> Value? {
        lastReferenced = .now
        return super.cachedItem()
    }

    public override func item() async -> Value? {
        lastReferenced = .now
        return await super.item()
    }
    
}

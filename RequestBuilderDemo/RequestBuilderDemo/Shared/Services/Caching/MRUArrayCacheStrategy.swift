//
//  MRUArrayCacheStrategy.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/1/25.
//

import Foundation

public class MRUArrayCacheStrategy<Key: Hashable, Value>: AsyncCacheStrategy {

    private var cache: [AsyncCacheEntry<Key, Value>] = []
    private var maxSize: Int
    private var dropCount: Int

    public init(maxSize: Int = 100, dropPercentage: Int = 10) {
        self.maxSize = max(maxSize, 1)
        self.dropCount = max(maxSize / dropPercentage, 1)
        self.cache.reserveCapacity(maxSize / 2)
    }

    public func findEntry(for key: Key) -> AsyncCacheEntry<Key, Value>? {
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

    public func newEntry(for key: Key, task: Task<Value?, Error>) -> AsyncCacheEntry<Key, Value> {
        if cache.count == maxSize {
            cache = Array(cache.dropFirst(dropCount))
        }
        let entry = AsyncCacheEntry(key: key, task: task)
        cache.append(entry)
        return entry
    }

    public func reset() {
        cache = []
    }

}

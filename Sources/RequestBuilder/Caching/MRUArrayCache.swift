//
//  MRUArrayCache.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/1/25.
//

import Foundation
import os

public class MRUArrayCache<Key: Hashable & Sendable, Value: Sendable>: CacheStrategy, @unchecked Sendable {

    private struct Entry {
        let key: Key
        let value: Value
    }

    private var cache: OSAllocatedUnfairLock<Array<Entry>> = .init(initialState: [])
    private var maxSize: Int
    private var dropCount: Int

    public init(maxSize: Int = 100, dropPercentage: Int = 10) {
        self.maxSize = max(maxSize, 1)
        self.dropCount = max(maxSize / dropPercentage, 1)
    }

    public func get(_ key: Key) -> Value? {
        cache.withLock { cache in
            if let index = cache.lastIndex(where: { $0.key == key }) {
                let entry = cache[index]
                if index < cache.count - 1 {
                    cache.remove(at: index)
                    cache.append(entry)
                }
                return entry.value
            }
            return nil
        }
    }

    public func set(_ key: Key, value: Value) {
        cache.withLock { cache in
            if cache.count == maxSize {
                cache = Array(cache.dropFirst(dropCount))
            }
            cache.append(Entry(key: key, value: value))
        }
    }

    public func remove(_ key: Key) {
        cache.withLock { cache in
            if let index = cache.lastIndex(where: { $0.key == key }) {
                cache.remove(at: index)
            }
        }
    }

    public func reset() {
        cache.withLock {
            $0 = []
        }
    }

}

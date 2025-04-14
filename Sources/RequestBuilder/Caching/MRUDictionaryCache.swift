//
//  MRUDictionaryCache.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/1/25.
//

import Foundation
import os

public class MRUDictionaryCache<Key: Hashable & Sendable, Value: Sendable>: CacheStrategy, @unchecked Sendable {

    private typealias CacheType = Dictionary<Key, Entry>

    private final class Entry: @unchecked Sendable {
        let key: Key
        let value: Value
        var timestamp: Date = .now
        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }

    private var cache: OSAllocatedUnfairLock<CacheType> = .init(initialState: [:])
    private var maxSize: Int
    private var dropCount: Int

    public init(maxSize: Int = 100, dropPercentage: Int = 10) {
        self.maxSize = max(maxSize, 1)
        self.dropCount = max(maxSize / dropPercentage, 1)
    }

    public func get(_ key: Key) -> Value? {
        cache.withLock { cache in
            if let entry = cache[key] {
                entry.timestamp = .now
                return entry.value
            }
            return nil
        }
    }

    public func set(_ key: Key, value: Value) {
        cache.withLock { cache in
            if cache.count == maxSize {
                // sweep and remove oldest entires
                cache.values
                    .sorted { $0.timestamp < $1.timestamp }
                    .prefix(dropCount)
                    .forEach { cache.removeValue(forKey: $0.key) }
            }
            cache[key] = Entry(key: key, value: value)
        }
    }

    public func remove(_ key: Key) {
        cache.withLock {
            _ = $0.removeValue(forKey: key)
        }
    }

    public func reset() {
        cache.withLock {
            $0 = [:]
        }
    }

}

//
//  CacheStrategy.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/2/25.
//

import Foundation
import os

public protocol CacheStrategy<Key, Value> {

    associatedtype Key: Hashable & Sendable
    associatedtype Value: Sendable

    func get(_ key: Key) -> Value?
    func set(_ key: Key, value: Value)

    func remove(_ key: Key)

    func reset()

}

extension CacheStrategy {

    func set(_ key: Key, value: Value?) {
        if let value = value {
            self.set(key, value: value)
        } else {
            self.remove(key)
        }
    }
    
}

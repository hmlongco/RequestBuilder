//
//  AsyncCacheEntry.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/1/25.
//

import Foundation

public class AsyncCacheEntry<Key: Hashable, Value> {

    public let key: Key

    private enum State: Error {
        case loading(Task<Value?, Error>)
        case loaded(Value)
        case error
    }

    private var state: State

    internal init(key: Key, task: Task<Value?, Error>) {
        self.key = key
        self.state = .loading(task)
    }

    deinit {
        if case let .loading(task) = state {
            task.cancel()
        }
    }

    @MainActor
    public func cachedItem() -> Value? {
        if case .loaded(let item) = state {
            return item
        }
        return nil
    }

    @MainActor
    public func item() async -> Value? {
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

    @MainActor
    public func cancel() {
        if case let .loading(task) = state {
            task.cancel()
            state = .error
        }
    }

}

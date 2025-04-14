//
//  AsyncSemaphore.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 3/6/25.
//

import Foundation

protocol AsyncSemaphore: Actor {
    func wait() async
    func signal()
}

actor LimitAsyncSemaphore: AsyncSemaphore {

    private var queue: [CheckedContinuation<Void, Never>] = []
    private let limit: Int
    private var count = 0

    init(limit: Int) {
        self.limit = limit
    }

    func wait() async {
        await withCheckedContinuation { continuation in
            if count < limit {
                count += 1
                continuation.resume()
            } else {
                queue.append(continuation)
            }
        }
    }

    func signal() {
        if let continuation = queue.first {
            queue.removeFirst()
            continuation.resume()
        } else {
            count = max(count - 1, 0)
        }
    }

}

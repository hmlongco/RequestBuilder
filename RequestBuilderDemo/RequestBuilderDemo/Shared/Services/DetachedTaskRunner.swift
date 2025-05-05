//
//  DetachedTaskRunner.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 4/25/25.
//

import Foundation

///    ```swift
///    let runner = DetachedTaskRunner<[User]>()
///
///    private func runTaskRunner() async throws -> [User] {
///        try await runner {
///            let users = try await self.service.list()
///            try Task.checkCancellation()
///            return users.sorted { ($0.name.last + $0.name.first).lowercased() < ($1.name.last + $1.name.first).lowercased() }
///        }
///    }
///    ```
public actor DetachedTaskRunner<Success: Sendable> {

    private var task: Task<Success, Error>!

    public init() {}

    /// Runs a new detached task, cancelling any previous one.
    @discardableResult 
    public func callAsFunction(_ operation: @escaping @Sendable () async throws -> Success) async throws -> Success {
        task?.cancel()

        self.task = Task.detached(priority: .background) {
            try Task.checkCancellation()
            return try await operation()
        }

        defer { task = nil }
        return try await task.value
    }

    deinit {
        task?.cancel()
    }

    /// Cancels the current task, if any.
    public func cancel() {
        task?.cancel()
    }

}

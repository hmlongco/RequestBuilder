//
//  UserImageCache.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import UIKit
import Factory
import Combine
import RequestBuilder

@MainActor
class UserImageCache {

    @Injected(\.sessionManager) private var session

    private var cache: [String: CacheEntry] = [:]
    private var maxSize: Int
    private var dropCount: Int

    nonisolated init(maxSize: Int = 100, dropPercentage: Int = 10) {
        self.maxSize = max(maxSize, 1)
        self.dropCount = max(maxSize / dropPercentage, 1)
    }

    // public interface

    func existingThumbnail(forUser user: User) -> UIImage? {
        guard let path = user.picture?.thumbnail, let image = findEntry(for: path)?.cachedImage() else {
            return nil
        }
        return image
    }

    func thumbnail(forUser user: User) async -> UIImage? {
        guard let path = user.picture?.thumbnail else {
            return nil
        }
        return await image(for: path)
    }

    func photo(forUser user: User) async -> UIImage? {
        guard let path = user.picture?.large else {
            return nil
        }
        return await image(for: path)
    }

    func cancelAll() {
        cache.values.forEach { $0.cancel() }
    }

    // core

    private func image(for path: String) async -> UIImage? {
        if let entry = findEntry(for: path) {
            return await entry.image()
        }
        let entry = CacheEntry(key: path, session: session)
        addEntry(entry)
        return await entry.image()
    }

    // cache management

    private func findEntry(for key: String) -> CacheEntry? {
        if let entry = cache[key] {
            return entry
        }
        return nil
    }

    private func addEntry(_ entry: CacheEntry) {
        if cache.count == maxSize {
            sweepAndRemoveOldestEntries()
        }
        cache[entry.key] = entry
    }

    private func sweepAndRemoveOldestEntries() {
        cache.values
            .sorted { $0.lastReferenced < $1.lastReferenced }
            .prefix(dropCount)
            .forEach { cache.removeValue(forKey: $0.key) }
    }

    func reset() {
        cache = [:]
    }

}

private class CacheEntry {

    let key: String

    private(set) var lastReferenced: Date = .now

    private enum State: Error {
        case loading(Task<UIImage?, Error>)
        case loaded(UIImage)
        case error
    }

    private var state: State = .error

    init(key: String, session: URLSessionManager) {
        self.key = key
        self.state = .loading(Task {
            let url = try URL.string(key)
            let data: Data = try await session.request(forURL: url).data()
            return await UIImage(data: data)?.byPreparingForDisplay()
        })
    }

    deinit {
        cancel()
    }

    @MainActor
    func cachedImage() -> UIImage? {
        if case .loaded(let image) = state {
            lastReferenced = .now
            return image
        }
        return nil
    }

    @MainActor
    func image() async -> UIImage? {
        lastReferenced = .now
        switch state {
        case .loading(let task):
            if let image = try? await task.value {
                state = .loaded(image)
                return image
            } else {
                state = .error
                return nil
            }
        case .loaded(let image):
            return image
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

extension URL {
    static func string(_ string: String) throws -> URL {
        guard let url = URL(string: string) else {
            throw URLError(.badURL)
        }
        return url
    }
}

//    private var cache: [CacheEntry] = []
//
//    private func findEntry(for key: String) -> CacheEntry? {
//        if let index = cache.lastIndex(where: { $0.key == key }) {
//            let entry = cache[index]
//            if index < cache.count - 1 {
//                cache.remove(at: index)
//                cache.append(entry)
//            }
//            return entry
//        }
//        return nil
//    }
//
//    private func addEntry(for key: String, entry: CacheEntry) {
//        if cache.count == maxSize {
//            cache = Array(cache.dropFirst(dropCount))
//        }
//        cache.append(entry)
//    }

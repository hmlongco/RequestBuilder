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

class UserImageCache {

    @Injected(\.sessionManager) private var session

    private let cache: any AsyncCacheStrategy<URL, UIImage>

    init(cache: any AsyncCacheStrategy<URL, UIImage>) {
        self.cache = cache
    }

    // public interface

    @MainActor
    func existingThumbnail(forUser user: User) -> UIImage? {
        guard let path = user.picture?.thumbnail, let url = URL(string: path), let image = cache.findEntry(for: url)?.cachedItem() else {
            return nil
        }
        return image
    }

    @MainActor
    func thumbnail(forUser user: User) async -> UIImage? {
        guard let path = user.picture?.thumbnail, let url = URL(string: path) else {
            return nil
        }
        return await image(for: url)
    }

    @MainActor
    func photo(forUser user: User) async -> UIImage? {
        guard let path = user.picture?.large, let url = URL(string: path) else {
            return nil
        }
        return await image(for: url)
    }

    @MainActor
    func reset() {
        cache.reset()
    }

    // core

    @MainActor
    private func image(for url: URL) async -> UIImage? {
        if let entry = cache.findEntry(for: url) {
            return await entry.item()
        }
        let entry = cache.newEntry(for: url, task: Task {
            // try await Task.sleep(for: .milliseconds(500))
            let data: Data = try await session.request(forURL: url).data()
            return await UIImage(data: data)?.byPreparingForDisplay()
        })
        return await entry.item()
    }

}

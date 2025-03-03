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
        guard let path = user.picture?.thumbnail, let url = URL(string: path), let image = cache.currentItem(for: url) else {
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
        await cache.item(for: url) {
            try await Task.sleep(for: .milliseconds(Int.random(in: 100...500))) // makes cached/uncached delay apparent
            let data: Data = try await self.session.request(forURL: url).data()
            return await UIImage(data: data)?.byPreparingForDisplay()
        }
    }

}

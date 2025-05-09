//
//  UserImageCache.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import UIKit
import FactoryKit
import Combine
import RequestBuilder

@MainActor
final class UserImageCache {

    @Injected(\.sessionManager) private var session

    private let cache: any AsyncCacheStrategy<URL, UIImage>

    nonisolated init(cache: any AsyncCacheStrategy<URL, UIImage>) {
        self.cache = cache
    }

    // public interface

    func existingThumbnail(forUser user: User) -> UIImage? {
        guard let path = user.picture?.thumbnail, let url = URL(string: path), let image = cache.currentItem(for: url) else {
            return nil
        }
        return image
    }

    func thumbnail(forUser user: User) async -> UIImage? {
        guard let path = user.picture?.thumbnail, let url = URL(string: path) else {
            return nil
        }
        return await image(for: url)
    }

    func photo(forUser user: User) async -> UIImage? {
        guard let path = user.picture?.large, let url = URL(string: path) else {
            return nil
        }
        return await image(for: url)
    }

    func reset() {
        cache.reset()
    }

    // core

    private func image(for url: URL) async -> UIImage? {
        await cache.item(for: url) { [session] in
            try await Task.sleep(for: .milliseconds(Int.random(in: 100...250)))
            let data: Data = try await session.request(forURL: url).data()
            return await UIImage(data: data)?.byPreparingForDisplay()
        }
    }

}

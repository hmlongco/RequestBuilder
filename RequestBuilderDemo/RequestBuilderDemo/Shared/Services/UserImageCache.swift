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

    @Injected(Container.sessionManager) private var session

    private enum ImageState: Error {
        case loading(Task<UIImage?, Never>)
        case loaded(UIImage)
        case error
    }

    private var cache = [String : ImageState]()

    func existingThumbnail(forUser user: User) -> UIImage? {
        guard let path = user.picture?.thumbnail, case let .loaded(image) = cache[path] else {
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

    private func image(for path: String) async -> UIImage? {
        if let state = cache[path] {
            switch state {
            case .loading(let task):
                return await task.value
            case .loaded(let image):
                return image
            case .error:
                break
            }
        }
        guard let url = URL(string: path) else {
            return nil
        }
        let task = Task<UIImage?, Never> {
            do {
                let data: Data = try await session.request(forURL: url).data()
                if let image = UIImage(data: data) {
                    cache[path] = .loaded(image)
                    return image
                } else {
                    cache[path] = .error
                    return nil
                }
            } catch {
                // nil if we want to allow for retry
                cache[path] = .error
                return nil
            }
        }
        cache[path] = .loading(task)
        return await task.value
    }

    func reset() {
        cache = [:]
    }

}

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

    @Injected(Container.sessionManager) private var session

    func existingThumbnail(forUser user: User) -> UIImage? {
        guard let key = user.picture?.thumbnail else {
            return nil
        }
        return imageCache.object(forKey: NSString(string: key))
    }

    func requestThumbnail(forUser user: User) -> AnyPublisher<UIImage?, Never> {
        cachedImage(for: user.picture?.thumbnail)
    }

    func requestPhoto(forUser user: User) -> AnyPublisher<UIImage?, Never> {
        cachedImage(for: user.picture?.large)
    }

    func reset() {
        imageCache = NSCache<NSString, UIImage>()
    }

    private func cachedImage(for path: String?) -> AnyPublisher<UIImage?, Never> {
        guard let path = path else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        let key = NSString(string: path)
        if let image = imageCache.object(forKey: key) {
            return Just(image)
                .eraseToAnyPublisher()
        }
        return image(for: path)
            .handleEvents(receiveOutput: { [weak imageCache] (image) in
                if let image = image {
                    imageCache?.setObject(image, forKey: key)
                }
            })
            .eraseToAnyPublisher()
    }

    private func image(for path: String) -> AnyPublisher<UIImage?, Never> {
        return session.request(forURL: URL(string: path))
            .data()
            .map(UIImage.init)
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }

    private var imageCache = NSCache<NSString, UIImage>()

}

//
//  UserImageCache.swift
//  LiveFrontDemo
//
//  Created by Michael Long on 8/30/22.
//

import UIKit
import Factory
import Combine
import RequestBuilder

class UserImageCache {

    @Injected(Container.sessionManager) private var session

    func thumbnail(forUser user: User) -> AnyPublisher<UIImage?, Never> {
        cachedImage(for: user.picture?.medium)
    }

    func photo(forUser user: User) -> AnyPublisher<UIImage?, Never> {
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
        if let image = imageCache.object(forKey: NSString(string: path)) {
            return Just(image)
                .eraseToAnyPublisher()
        }
        return image(for: path)
            .handleEvents(receiveOutput: { [weak imageCache] (image) in
                if let image = image {
                    imageCache?.setObject(image, forKey: NSString(string: path))
                }
            })
            .eraseToAnyPublisher()
    }

    private func image(for path: String) -> AnyPublisher<UIImage?, Never> {
        return session.request(forURL: URL(string: path))
            .data()
            .map(UIImage.init)
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private var imageCache = NSCache<NSString, UIImage>()

}

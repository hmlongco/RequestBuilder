//
//  MainListCardView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI
import Combine
import Factory

struct MainListCardView: View {

    let user: User

    @State private var photo: UIImage?

    private let images = Container.userImageCache()

    var body: some View {
        let _ = Self._printChanges()
        HStack(spacing: 12) {
            ZStack {
                if let thumbnail = cachedThumbnail() {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image("User-Unknown")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onReceive(requestThumbnail()) {
                            photo = $0
                        }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(user.fullname)
                    .font(.headline)
                if let email = user.email {
                    Text(email)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
            Spacer()
        }
    }

    func cachedThumbnail() -> UIImage? {
        photo ?? images.existingThumbnail(forUser: user)
    }

    func requestThumbnail() -> AnyPublisher<UIImage?, Never> {
        images.requestThumbnail(forUser: user)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

}

struct MainListCardView_Previews: PreviewProvider {
    static var previews: some View {
        MainListCardView(user: User.mockJQ)
            .padding()
    }
}


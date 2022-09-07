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
        HStack {
            ZStack {
                if let image = photo {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image("User-Unknown")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .onReceive(cachedThumbnail()) { image in
                self.photo = image
            }

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

    func cachedThumbnail() -> AnyPublisher<UIImage?, Never> {
        images.thumbnail(forUser: user)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

}

struct MainListCardView_Previews: PreviewProvider {
    static var previews: some View {
        MainListCardView(user: User.mockJQ)
            .padding()
    }
}

//
//  MainListCardView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI
import Combine
import FactoryKit

struct MainListCardView: View {

    let user: User

    @State private var photo: UIImage?

    @Injected(\.userImageCache) var images

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let thumbnail = existingThumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image("User-Unknown")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .task {
                            photo = await images.thumbnail(forUser: user)
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

    var existingThumbnail: UIImage? {
        photo ?? images.existingThumbnail(forUser: user)
    }
}

#Preview {
    MainListCardView(user: User.mockJQ)
        .padding()
}

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
                if let image = photo ?? images.existingThumbnail(forUser: user) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image("User-Unknown")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onReceive(images.requestThumbnail(forUser: user)) {
                            // print("onReceive \(user.picture?.thumbnail)")
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

    func loadThumbnail() -> AnyPublisher<UIImage?, Never> {
        images.requestThumbnail(forUser: user)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

}

struct MainListCardView2: View {

    let user: User

    @StateObject private var viewModel = MainListCardViewModel()

    var body: some View {
        let _ = Self._printChanges()
        HStack {
            ZStack {
                Image("User-Unknown")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                if let image = viewModel.photo {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .onAppear {
//                print("onAppear \(user.picture?.thumbnail)")
                viewModel.loadThumbnail(for: user)
            }

            VStack(alignment: .leading) {
                Text(user.fullname)
                    .font(.headline)
                if let email = user.email {
                    Text(email)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                if let thumb = user.picture?.thumbnail, let url = URL(string: thumb), let last = url.lastPathComponent {
                    Text(last)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
            Spacer()
        }
    }
}

class MainListCardViewModel: ObservableObject {

    @Published var photo: UIImage?

    private let images = Container.userImageCache()
    private var cancellable: AnyCancellable?

    func loadThumbnail(for user: User) {
        guard photo == nil else {
            return
        }
        cancellable = images.requestThumbnail(forUser: user)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { photo in
                self.photo = photo
            })
    }
}

struct MainListCardView_Previews: PreviewProvider {
    static var previews: some View {
        MainListCardView(user: User.mockJQ)
            .padding()
    }
}


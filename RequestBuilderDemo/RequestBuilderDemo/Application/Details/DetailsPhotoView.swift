//
//  DetailsCardView.swift
//  LiveFrontDemo
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI
import Combine

struct DetailsPhotoView: View {

    let photo: AnyPublisher<UIImage?, Never>
    let name: String

    @State private var image: UIImage?

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("User-Unknown")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(maxHeight: 300)
            .clipShape(Rectangle())

            HStack {
                Spacer()
                Text(name)
                    .font(.title)
                    .foregroundColor(.white)
            }
            .padding(10)
            .background(
                Color.black
                    .opacity(0.6)
            )
        }
        .frame(maxHeight: 300)
        .background(Color(.lightGray))
        .onReceive(photo) { image in
            self.image = image
        }
    }

}

struct DetailsPhotoView_Previews: PreviewProvider {
    static var photo = Just(UIImage(named: "User-JQ")).eraseToAnyPublisher()
    static var previews: some View {
        VStack {
            DetailsPhotoView(photo: photo, name: "Michael Long")
            Spacer()
        }
    }
}

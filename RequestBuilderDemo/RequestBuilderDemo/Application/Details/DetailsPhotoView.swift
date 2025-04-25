//
//  DetailsCardView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI
import Combine

struct DetailsPhotoView: View {

    let photo: UIImage?
    let name: String

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if let image = photo {
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
    }

}

#Preview {
    VStack {
        DetailsPhotoView(photo: UIImage(named: "User-JQ"), name: "Michael Long")
        Spacer()
    }
}

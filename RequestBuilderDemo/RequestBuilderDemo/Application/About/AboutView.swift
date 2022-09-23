//
//  AboutView.swift
//  RequestBuilderDemo
//
//  Created by Michael Long on 9/23/22.
//

import SwiftUI

struct AboutView: View {

    @Binding var presentAbout: Bool

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    presentAbout.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                }
            }
            .padding()

            ScrollView {
                VStack(spacing: 20) {
                    Image("HML")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300)
                        .clipShape(Circle())

                    VStack {
                        Text("RequestBuilder Demo")
                            .font(.title)
                        Text("By Michael Long")
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    Text("This demo application was written in Swift using SwiftUI, Combine, RequestBuilder, and Factory.")
                        .multilineTextAlignment(.center)

                    Divider()

                    VStack(alignment: .leading, spacing: 15) {
                        link("RequestBuilder - Networking Library", to: "https://github.com/hmlongco/Factory")
                        link("Factory - Dependency Injection System", to: "https://github.com/hmlongco/ResultBuilder")
                        link("GitHub Profile", to: "https://github.com/hmlongco")
                        link("LinkedIn Profile", to: "https://www.linkedin.com/in/hmlong/")
                        link("Medium Articles on Swift, SwiftUI, and more.", to: "https://medium.com/@michaellong")
                    }
                 }
                .padding(20)
            }
        }
        .background(Image("vector"))
    }

    @ViewBuilder
    func link(_ title: String, to destination: String) -> some View {
        if let url = URL(string: destination) {
            HStack {
                Image(systemName: "globe")
                Link(title, destination: url)
            }
            .foregroundColor(.accentColor)
            .font(.callout)
        } else {
            EmptyView()
        }
    }

}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(presentAbout: .constant(true))
    }
}

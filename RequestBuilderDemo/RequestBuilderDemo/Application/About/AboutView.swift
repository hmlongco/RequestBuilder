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
                        Text("Version 1.0")
                            .foregroundColor(.secondary)
                        Text("By Michael Long")
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    Text("Written in Swift using SwiftUI, Combine, RequestBuilder, and Factory.")
                        .multilineTextAlignment(.center)

                    Divider()

                    VStack(alignment: .leading, spacing: 15) {
                        External(link: "https://github.com/hmlongco/Factory", title: "RequestBuilder - Networking Library")
                        External(link: "https://github.com/hmlongco/ResultBuilder", title: "Factory - Dependency Injection System")
                        External(link: "https://github.com/hmlongco", title: "GitHub Profile")
                        External(link: "https://www.linkedin.com/in/hmlong/", title: "LinkedIn Profile")
                        External(link: "https://medium.com/@michaellong", title: "Medium Articles on Swift, SwiftUI, and more.")
                    }
                 }
                .padding(20)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
    }

}

private struct External: View {

    let link: String
    let title: String

    @State private var presentAlert = false

    var body: some View {
        if let url = URL(string: link) {
            HStack {
                Image(systemName: "globe")
                Button(title) {
                    presentAlert.toggle()
                }
                .alert("External Link", isPresented: $presentAlert) {
                    Button("Open") {
                        UIApplication.shared.open(url)
                    }
                    Button("Cancel", role: .cancel) {}
               } message: {
                    Text("Launch '\(title)' in external browser?")
                }
            }
            .foregroundColor(.accentColor)
            .font(.footnote)
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

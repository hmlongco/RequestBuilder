//
//  StandardEmptyView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI

struct StandardEmptyView: View {

    let message: String
    var retry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)

            if let retry = retry {
                Button("Try Again") {
                    retry()
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct StandardEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        StandardEmptyView(message: "Nothing was found. Move along.")
    }
}

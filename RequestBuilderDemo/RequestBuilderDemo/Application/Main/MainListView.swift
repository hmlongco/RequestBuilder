//
//  MainListView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI

struct MainListView: View {

    let users: [User]

    @State var text = ""

    var body: some View {
        List(users) { user in
            NavigationLink(value: user) {
                MainListCardView(user: user)
            }
        }
        .navigationDestination(for: User.self) { user in
            DetailsView(user: user)
        }
        .navigationTitle("Active Users")
    }

}

#Preview {
    NavigationStack {
        MainListView(users: User.mockUsers)
    }
}

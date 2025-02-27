//
//  MainListView.swift
//  RequestBuilder
//
//  Created by Michael Long on 8/30/22.
//

import SwiftUI

struct MainListView: View {

    let users: [User]

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

struct MainListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MainListView(users: User.users)
        }
    }
}

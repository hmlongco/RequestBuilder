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
        List {
            ForEach(users) { user in
                NavigationLink(destination: DetailsView(user: user)) {
                    MainListCardView(user: user)
                }
            }
        }
        .navigationTitle("RequestBuilder")
    }

}

struct MainListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainListView(users: User.users)
        }
    }
}
